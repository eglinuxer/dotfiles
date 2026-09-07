"""Isolated integration test: real tmux client input, panes, mode and OSC 52.
Run from any directory. Uses only a private temporary server; always cleans up.
"""
import base64
import fcntl
import os
from pathlib import Path
import pty
import select
import shlex
import struct
import subprocess
import tempfile
import termios
import time

ROOT = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='dotfiles-tmux-') as directory:
    temp = Path(directory)
    sock = str(temp / 'socket')
    env = dict(os.environ, TERM='xterm-256color', TERM_PROGRAM='wezterm')
    env.pop('TMUX', None)
    command = ['tmux', '-S', sock]
    master = None
    client = None
    transcript = bytearray()

    def tm(*args):
        result = subprocess.run(command + list(args), env=env, text=True, capture_output=True, timeout=10)
        assert result.returncode == 0, (args, result.stderr)
        return result.stdout.strip()

    def drain(seconds=.12):
        end = time.monotonic() + seconds
        while time.monotonic() < end:
            if master is not None and select.select([master], [], [], .02)[0]:
                try:
                    data = os.read(master, 65536)
                    if not data: break
                    transcript.extend(data)
                except OSError:
                    break

    def key(data):
        os.write(master, data)
        drain()

    def fmt(value):
        return tm('display-message', '-p', value)

    def start_client():
        global master, client
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 36, 120, 0, 0))
        client = subprocess.Popen(command + ['attach-session', '-t', 'validation'], env=env, stdin=slave, stdout=slave, stderr=slave, start_new_session=True)
        os.close(slave)
        drain(.4)

    try:
        # Use a raw input recorder as the application; avoids the user's shell rc.
        recorder = temp / 'recorder.py'
        recorder.write_text('import os,tty,sys\ntty.setraw(0)\nf=open(sys.argv[1],"ab",buffering=0)\nprint("\\x1b[?2004hREADY",flush=True)\nwhile True:\n d=os.read(0,4096)\n f.write(d)\n')
        received = temp / 'received'
        app = shlex.join(['python3', str(recorder), str(received)])
        tm('-f', str(ROOT/'tmux/tmux.conf'), 'new-session', '-d', '-s', 'validation', '-c', directory, app)
        tm('set-option', '-g', 'default-shell', '/bin/sh')
        # Explicit test terminal capability, never broad overrides in production.
        tm('set-option', '-as', 'terminal-features', ',xterm-256color:clipboard:RGB:extkeys')
        start_client()
        assert fmt('#{session_attached}') == '1'
        first = fmt('#{pane_id}')
        assert tm('show-option','-gv','prefix') == 'C-a'
        assert tm('show-option','-gv','history-limit') == '50000'
        assert tm('show-option','-sv','set-clipboard') == 'on'
        for control in (b'\x08', b'\x0a', b'\x0b', b'\x0c', b'\x1bb', b'\x1bf', b'\x1bOP', b'\x1b[1;5D'):
            before = received.read_bytes()
            key(control)
            assert received.read_bytes()[len(before):] == control, ('intercepted', control)
        before = received.read_bytes()
        key(b'\x01\x01')
        assert received.read_bytes()[len(before):] == b'\x01'
        key(b'\x01|')
        second = fmt('#{pane_id}')
        assert second != first
        assert fmt('#{pane_current_path}') == directory
        key(b'\x01h')
        assert fmt('#{pane_id}') == first
        key(b'\x01h')
        assert fmt('#{pane_id}') == first, 'left edge wrapped'
        key(b'\x01z')
        key(b'\x01l')
        assert fmt('#{pane_id}') == first and fmt('#{window_zoomed_flag}') == '1'
        assert 'ZOOM' in fmt('#{E:status-right}')
        key(b'\x01z')
        width = int(fmt('#{pane_width}'))
        key(b'\x01r')
        assert 'RESIZE' in fmt('#{E:status-right}')
        key(b'll')
        assert int(fmt('#{pane_width}')) == width+4
        key(b'q')
        assert fmt('#{client_key_table}') == 'root'
        # Any unrecognised resize key is swallowed and exits the mode.
        before = received.read_bytes()
        key(b'\x01rx')
        assert fmt('#{client_key_table}') == 'root'
        assert received.read_bytes() == before
        key(b'\x01r')
        key(b'\x1b')
        drain(.5)
        assert fmt('#{client_key_table}') == 'root'
        key(b'\x01x')
        assert fmt('#{session_windows}') == '1'
        assert first in tm('list-panes','-F','#{pane_id}')
        key(b'n')
        key(b'\x01c')
        assert fmt('#{window_index}') == '2' and fmt('#{pane_current_path}') == directory
        key(b'\x01c')
        assert fmt('#{window_index}') == '3'
        tm('kill-window','-t','validation:2')
        assert fmt('#{window_index}') == '3', 'window numbers changed'
        tm('select-window','-t','validation:1')
        tm('select-pane','-t',first)
        # A known OSC52 emitted by an application must emerge at the outer client.
        sentinel = 'dotfiles OSC52 中文'
        encoded = base64.b64encode(sentinel.encode()).decode()
        tm('split-window','-d','-c',directory, 'printf ' + shlex.quote('\033]52;c;'+encoded+'\a') + '; sleep 2')
        drain(.4)
        assert encoded.encode() in transcript, 'OSC52 did not emerge from tmux'
        assert tm('show-buffer') == sentinel
        # Bracketed paste reaches the application as one bracketed sequence.
        tm('send-keys','-t',first,'')
        tm('set-buffer','MULTI\nLINE')
        before = received.read_bytes()
        key(b'\x01]')
        actual_paste = received.read_bytes()[len(before):]
        assert actual_paste == b'\x1b[200~MULTI\rLINE\x1b[201~', repr(actual_paste)
        # Real copy-mode operations: retain selection, keyboard copy exits, search.
        tm('new-window','-n','history','/bin/sh -c '+shlex.quote("printf 'alpha marker\\nbeta marker\\n'; exec /bin/sh"))
        drain(.3)
        # SGR mouse drag/release enters copy mode and preserves its selection.
        key(b'\x1b[<0;1;1M')
        key(b'\x1b[<32;5;1M')
        key(b'\x1b[<0;5;1m')
        assert fmt('#{pane_in_mode}') == '1', 'mouse drag left copy mode'
        assert tm('show-buffer') == 'alpha', 'mouse release failed to copy selection'
        key(b'q')
        key(b'\x01[')
        assert fmt('#{pane_in_mode}') == '1' and 'COPY' in fmt('#{E:status-right}')
        tm('send-keys','-X','history-top')
        tm('send-keys','-X','start-of-line')
        key(b'vllll')
        tm('send-keys','-X','copy-selection-no-clear')
        assert fmt('#{pane_in_mode}') == '1'
        assert tm('show-buffer') == 'alpha'
        key(b'y')
        assert fmt('#{pane_in_mode}') == '0'
        key(b'\x01/')
        key(b'alpha\r')
        assert fmt('#{pane_in_mode}') == '1'
        key(b'q')
        assert fmt('#{pane_in_mode}') == '0'
        tm('kill-window')
        tm('select-window','-t','validation:1')
        tm('select-pane','-t',first)
        # Detach via actual prefix, retain same live pane, then reattach.
        pid = fmt('#{pane_pid}')
        key(b'\x01d')
        client.wait(timeout=3)
        assert fmt('#{session_attached}') == '0'
        assert fmt('#{pane_pid}') == pid
        os.close(master)
        master = None
        start_client()
        assert fmt('#{pane_pid}') == pid and fmt('#{session_attached}') == '1'
        # Idempotent reload, no appended capability or status strings.
        state = tm('show-options','-g')
        tm('source-file',str(ROOT/'tmux/tmux.conf'))
        assert tm('show-options','-g') == state
        print('PASS: real client key passthrough, prefix, cwd, navigation/zoom, resize exits, confirmation, stable numbering, OSC52, bracketed paste, copy/search, detach/reattach, reload')
    finally:
        subprocess.run(command + ['kill-server'], env=env, capture_output=True)
        if client:
            try: client.wait(timeout=3)
            except subprocess.TimeoutExpired: client.kill(); client.wait()
        if master is not None: os.close(master)
