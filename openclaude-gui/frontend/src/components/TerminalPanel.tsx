import React, { useEffect, useRef } from 'react';
import { Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';
import { io, Socket } from 'socket.io-client';
import 'xterm/css/xterm.css';

interface TerminalPanelProps {
  sessionId: string;
}

export default function TerminalPanel({ sessionId }: TerminalPanelProps) {
  const terminalRef = useRef<HTMLDivElement>(null);
  const xtermRef = useRef<Terminal | null>(null);
  const socketRef = useRef<Socket | null>(null);

  useEffect(() => {
    if (!terminalRef.current) return;

    // Initialize Terminal
    const term = new Terminal({
      cursorBlink: true,
      theme: {
        background: 'transparent',
        foreground: '#ffffff',
        cursor: '#C8A8E9',
        selection: 'rgba(200, 168, 233, 0.3)',
      },
      fontSize: 14,
      fontFamily: 'JetBrains Mono, Fira Code, monospace',
    });
    xtermRef.current = term;

    const fitAddon = new FitAddon();
    term.loadAddon(fitAddon);
    term.open(terminalRef.current);
    fitAddon.fit();

    // Initialize Socket
    const socket = io('http://localhost:3001');
    socketRef.current = socket;

    // Join session
    // In a real app, we'd get the path from state, but for now we use a default or prompt
    const path = prompt('Enter absolute path for this session:') || process.cwd();
    socket.emit('join-session', { sessionId, directory: path });

    // Handle output from backend
    socket.on('output', (data: string) => {
      term.write(data);
    });

    // Handle input from terminal
    term.onData((data) => {
      socket.emit('input', { sessionId, data });
    });

    // Handle resize
    const handleResize = () => {
      fitAddon.fit();
      socket.emit('resize', {
        sessionId,
        cols: term.cols,
        rows: term.rows,
      });
    };

    window.addEventListener('resize', handleResize);
    handleResize();

    return () => {
      socket.disconnect();
      term.dispose();
      window.removeEventListener('resize', handleResize);
    };
  }, [sessionId]);

  return (
    <div ref={terminalRef} className="h-full w-full p-2" />
  );
}
