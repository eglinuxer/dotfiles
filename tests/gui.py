"""Run inside a dedicated WezTerm window. Saves/restores clipboard in memory.
Writes only pass/fail information to argv[1]; never logs clipboard contents.
"""
import base64
import os
from pathlib import Path
import select
import shlex
import subprocess
import sys
import tempfile
import termios
import time
import tty

ROOT = Path(__file__).resolve().parents[1]
report = Path(sys.argv[1])
original = None
attrs = termios.tcgetattr(0)
checks = []

def write_clip(value):
    os.write(1, b'\x1b]52;c;' + base64.b64encode(value) + b'\x1b\\')

# Verify against the OS clipboard, not an OSC52 read (WezTerm may deny reads).
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk
clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
def read_clip():
    # Process desktop ownership changes before using GTK's clipboard cache.
    while Gtk.events_pending(): Gtk.main_iteration_do(False)
    value = clipboard.wait_for_text()
    if value is None:
        raise RuntimeError('Clipboard is not text; leave it untouched')
    return value.encode()

def expect_clip(value):
    end = time.monotonic() + 3
    while time.monotonic() < end:
        if read_clip() == value: return True
        time.sleep(.05)
    return False

try:
    tty.setraw(0)
    original = read_clip()
    token = 'dotfiles GUI clipboard 中文\nline 2'.encode()
    write_clip(token)
    time.sleep(.2)
    assert expect_clip(token)
    checks.append('real WezTerm desktop clipboard write/read')
    with tempfile.TemporaryDirectory(prefix='dotfiles-gui-') as directory:
        socket = directory + '/tmux.sock'
        env = dict(os.environ, SSH_CONNECTION='validation only', NVIM_LOG_FILE=directory+'/nvim.log', XDG_STATE_HOME=directory+'/state', XDG_CACHE_HOME=directory+'/cache')
        env.pop('TMUX',None)
        token2 = 'Neovim to tmux to WezTerm 中文'
        # The user can only yank after the TUI and tmux terminal negotiation are
        # ready; do not send clipboard output during the attach handshake.
        action = "lua vim.defer_fn(function() vim.fn.setreg('+', '"+token2+"'); vim.defer_fn(function() vim.cmd('qa!') end, 500) end, 1500)"
        nvim = shlex.join(['nvim','-u',str(ROOT/'nvim/init.lua'),'-i','NONE','-c',action])
        # The child detaches the test client; the parent can then query WezTerm.
        child = nvim + '; tmux detach-client; sleep 30'
        cmd = ['tmux','-S',socket,'-f',str(ROOT/'tmux/tmux.conf')]
        try:
            result = subprocess.run(cmd+['new-session','-s','gui-test',child],env=env,cwd=directory,timeout=15)
            assert result.returncode == 0
            tty.setraw(0)
            time.sleep(.2)
            assert expect_clip(token2.encode()), 'Neovim/tmux OSC52 clipboard mismatch'
            checks.append('real Neovim SSH-provider -> tmux -> WezTerm desktop clipboard')
            pid = subprocess.check_output(cmd+['display-message','-p','#{pane_pid}'],env=env)
            assert pid.strip()
            checks.append('GUI tmux detach leaves its process alive')
        finally:
            subprocess.run(cmd+['kill-server'],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    # Verify actual WezTerm paste bracket framing, using its own CLI.
    os.write(1,b'\x1b[?2004h')
    paste = subprocess.Popen(['wezterm','cli','send-text','--pane-id',os.environ['WEZTERM_PANE'],'one\ntwo'],stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
    data=b''
    end=time.monotonic()+3
    while time.monotonic()<end and b'\x1b[201~' not in data:
        if select.select([0],[],[],.1)[0]: data+=os.read(0,4096)
    paste.wait(timeout=3)
    assert data == b'\x1b[200~one\ntwo\x1b[201~', 'bracketed paste framing mismatch'
    checks.append('WezTerm multiline bracketed paste')
    report.write_text('PASS\n'+'\n'.join(checks)+'\n')
except Exception as error:
    report.write_text('FAIL: '+str(error)+'\n'+'\n'.join(checks)+'\n')
finally:
    os.write(1,b'\x1b[?2004l')
    if original is not None: write_clip(original)
    termios.tcsetattr(0,termios.TCSANOW,attrs)
