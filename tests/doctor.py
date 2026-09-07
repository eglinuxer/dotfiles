"""Read-only prerequisite/config check; no install and no default tmux server."""
from pathlib import Path
import re
import argparse
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
errors = []
parser = argparse.ArgumentParser()
parser.add_argument("--remote", action="store_true", help="check tmux/Neovim only; no GUI required")
options = parser.parse_args()
for binary, args in [('tmux',['-V']),('nvim',['--version']),('wezterm',['--version'])]:
    if options.remote and binary == 'wezterm': continue
    if not shutil.which(binary):
        print('MISSING:',binary); errors.append(binary); continue
    p=subprocess.run([binary]+args,capture_output=True,text=True)
    print(p.stdout.splitlines()[0] if p.stdout else p.stderr.strip())
    if binary == 'tmux':
        m=re.search(r'(\d+)\.(\d+)',p.stdout)
        if not m or tuple(map(int,m.groups())) < (3,2): errors.append('tmux >= 3.2 required')
    if binary == 'nvim':
        m=re.search(r'v(\d+)\.(\d+)',p.stdout)
        if not m or tuple(map(int,m.groups())) < (0,11): errors.append('Neovim >= 0.11 required')
if shutil.which('infocmp'):
    p=subprocess.run(['infocmp','tmux-256color'],capture_output=True)
    print('tmux-256color:', 'OK' if p.returncode == 0 else 'MISSING')
    if p.returncode: errors.append('tmux-256color terminfo')
else:
    print('infocmp missing; terminfo not checked'); errors.append('infocmp')
if not options.remote and shutil.which('wezterm'):
    p=subprocess.run(['wezterm','--config-file',str(root/'wezterm/wezterm.lua'),'show-keys','--lua'],capture_output=True,text=True)
    if p.returncode or 'ERROR' in p.stderr:
        print(p.stderr);errors.append('WezTerm configuration')
    else: print('WezTerm native config parser: OK')
print('lazygit:', 'available' if shutil.which('lazygit') else 'optional, not installed')
print('RESULT:', 'FAIL: '+', '.join(errors) if errors else 'PASS')
sys.exit(bool(errors))
