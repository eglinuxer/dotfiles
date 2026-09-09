#!/usr/bin/env python3
"""Check/update the vendored Catppuccin theme from official stable releases."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import tarfile
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'vendor/catppuccin'
API = 'https://api.github.com/repos/catppuccin/tmux/releases/latest'
FILES = {'catppuccin_options_tmux.conf', 'catppuccin_tmux.conf', 'LICENSE'}
DIRS = {'themes', 'status', 'utils'}


def fetch(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'dotfiles-theme-updater'})
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read()


def validate(staged, temporary):
    # Test the project's theme settings against the candidate on a private server.
    config = temporary / 'validate.conf'
    config.write_text((ROOT / 'conf.d/30-theme.conf').read_text().replace(
        '#{d:current_file}/../vendor/catppuccin', str(staged)))
    command = ['tmux', '-S', str(temporary / 'socket')]
    try:
        result = subprocess.run(command + ['-f', str(config), 'new-session', '-d',
                                '-s', 'theme-check', '/bin/sleep 30'],
                                capture_output=True, text=True, timeout=15)
        if result.returncode or result.stderr.strip():
            raise RuntimeError(f'Theme validation failed: {result.stderr}')
        result = subprocess.run(command + ['display-message', '-p',
                                '#{E:status-right}'], capture_output=True,
                                text=True, check=True, timeout=10)
        if not all(icon in result.stdout for icon in ('', '')):
            raise RuntimeError('Theme validation failed: missing application/session modules')
    finally:
        subprocess.run(command + ['kill-server'], capture_output=True, timeout=10)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='only check for a newer release')
    parser.add_argument('--version', help='install a specific tag, e.g. v2.3.0 (also permits rollback)')
    args = parser.parse_args()
    lock = DEST / 'upstream.json'
    current = json.loads(lock.read_text()).get('version') if lock.exists() else None
    version = args.version or json.loads(fetch(API))['tag_name']
    if not re.fullmatch(r'v\d+\.\d+\.\d+', version):
        raise ValueError(f'Unsupported stable release tag: {version!r}')
    print(f'Installed: {current or "unknown"}; upstream target: {version}')
    if args.check or (current == version and not args.version):
        return

    url = f'https://codeload.github.com/catppuccin/tmux/tar.gz/refs/tags/{version}'
    data = fetch(url)
    DEST.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='.theme-update-', dir=DEST.parent) as directory:
        temporary = Path(directory)
        archive = temporary / 'release.tar.gz'
        archive.write_bytes(data)
        staged = temporary / 'catppuccin'
        staged.mkdir()
        with tarfile.open(archive) as source:
            for member in source.getmembers():
                parts = PurePosixPath(member.name).parts[1:]
                if not parts or '..' in parts or member.name.startswith('/'):
                    continue
                if not (parts[0] in DIRS or (len(parts) == 1 and parts[0] in FILES)):
                    continue
                if not member.isfile():
                    continue
                target = staged.joinpath(*parts)
                target.parent.mkdir(parents=True, exist_ok=True)
                with source.extractfile(member) as contents:
                    target.write_bytes(contents.read())
        for name in FILES | {'themes/catppuccin_mocha_tmux.conf',
                             'status/application.conf', 'status/session.conf',
                             'utils/status_module.conf'}:
            if not (staged / name).is_file():
                raise RuntimeError(f'Upstream layout changed: missing {name}')
        (staged / 'upstream.json').write_text(json.dumps({
            'repository': 'https://github.com/catppuccin/tmux',
            'version': version, 'archive_url': url,
            'sha256': hashlib.sha256(data).hexdigest(),
        }, indent=2) + '\n')
        (staged / 'UPSTREAM.md').write_text(
            '# Catppuccin tmux\n\n'
            f'Original runtime files from https://github.com/catppuccin/tmux/tree/{version}.\n'
            'Includes the original MIT LICENSE. Version and archive SHA-256: upstream.json.\n'
            'Local settings: ../../conf.d/30-theme.conf. Update: ../../scripts/update-theme.py.\n'
            'No upstream runtime files are modified. No installation runs at startup.\n')
        validate(staged, temporary)
        backup = temporary / 'previous'
        if DEST.exists():
            DEST.rename(backup)
        try:
            staged.rename(DEST)
        except BaseException:
            if backup.exists():
                backup.rename(DEST)
            raise
    print(f'Installed and validated {version}. Review the diff, then reload tmux with prefix + R.')


if __name__ == '__main__':
    main()
