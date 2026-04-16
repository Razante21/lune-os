import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import * as pty from 'node-pty';
import path from 'path';

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: '*',
  },
});

const sessions = new Map<string, { pty: pty.IPty, socketId: string }>();

io.on('connection', (socket) => {
  console.log(`Client connected: ${socket.id}`);

  socket.on('join-session', ({ sessionId, directory }) => {
    console.log(`Joining session ${sessionId} in ${directory}`);

    let session = sessions.get(sessionId);

    if (!session) {
      // Spawn a new PTY process
      const shell = process.platform === 'win32' ? 'powershell.exe' : 'bash';

      const ptyProcess = pty.spawn(shell, [], {
        name: 'xterm-color',
        cols: 80,
        rows: 24,
        cwd: directory,
        env: process.env,
      });

      session = { pty: ptyProcess, socketId: socket.id };
      sessions.set(sessionId, session);

      // Pipe PTY output to Socket.io
      ptyProcess.onData((data) => {
        io.to(session.socketId).emit('output', data);
      });
    } else {
      // Update existing session with new socket ID
      session.socketId = socket.id;
    }

    socket.join(sessionId);
    socket.emit('session-joined', { sessionId });
  });

  socket.on('input', ({ sessionId, data }) => {
    const session = sessions.get(sessionId);
    if (session) {
      session.pty.write(data);
    }
  });

  socket.on('resize', ({ sessionId, cols, rows }) => {
    const session = sessions.get(sessionId);
    if (session) {
      session.pty.resize(cols, rows);
    }
  });

  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
    // We keep the PTY alive even if the client disconnects
    // so they can rejoin the session later.
  });
});

const PORT = 3001;
httpServer.listen(PORT, () => {
  console.log(`OpenClaude GUI Backend running on http://localhost:${PORT}`);
});
