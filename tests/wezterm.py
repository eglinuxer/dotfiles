"""Run native Lua checks and detect WezTerm's silent default-config fallback."""
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
result = subprocess.run(
    ['wezterm', '--config-file', str(root / 'tests/wezterm.lua'), 'show-keys', '--lua'],
    capture_output=True, text=True, timeout=30,
)
if result.returncode or 'DOTFILES_WEZTERM_TEST_PASS' not in result.stdout:
    print('FAIL: native WezTerm tests did not complete')
    print(result.stderr.strip())
    for line in result.stdout.splitlines():
        if 'DOTFILES_WEZTERM_TEST_FAIL' in line:
            print(line.strip())
    sys.exit(1)
print('PASS: native WezTerm keys, rounded tabs, background transitions, window isolation and missing-image fallback')
