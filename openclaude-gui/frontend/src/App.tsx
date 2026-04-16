import React, { useState, useEffect } from 'react';
import SessionNav from './components/SessionNav';
import TerminalPanel from './components/TerminalPanel';
import { Layout } from 'lucide-react';

export default function App() {
  const [sessions, setSessions] = useState<{ id: string, path: string }[]>([]);
  const [activeSessionId, setActiveSessionId] = useState<string | null>(null);

  const createSession = (path: string) => {
    const id = `session-${Date.now()}`;
    setSessions(prev => [...prev, { id, path }]);
    setActiveSessionId(id);
  };

  return (
    <div className="flex h-screen w-full bg-[#0f0f1a] text-white font-sans overflow-hidden">
      {/* Sidebar */}
      <SessionNav
        sessions={sessions}
        activeSessionId={activeSessionId}
        onSelectSession={setActiveSessionId}
        onCreateSession={createSession}
      />

      {/* Main Content */}
      <main className="flex-1 relative flex flex-col h-full transition-all duration-500 ease-in-out">
        {activeSessionId ? (
          <div className="h-full w-full p-6 flex flex-col gap-6">
            <div className="flex items-center justify-between glass p-4">
              <div className="flex items-center gap-3">
                <div className="w-3 h-3 rounded-full bg-[#C8A8E9] animate-pulse" />
                <span className="text-sm font-medium opacity-80">
                  Session: {activeSessionId}
                </span>
              </div>
              <div className="text-xs opacity-50 flex items-center gap-2">
                <Layout size={12} />
                OpenClaude Bridge Active
              </div>
            </div>

            <div className="flex-1 relative glass overflow-hidden">
              <TerminalPanel sessionId={activeSessionId} />
            </div>
          </div>
        ) : (
          <div className="h-full w-full flex flex-col items-center justify-center text-center p-12">
            <div className="w-24 h-24 lune-gradient rounded-3xl rotate-12 mb-8 blur-2xl opacity-20 absolute" />
            <h1 className="text-5xl font-bold mb-4 relative z-10 bg-clip-text text-transparent bg-gradient-to-r from-[#C8A8E9] to-[#7EB8F7]">
              OpenClaude GUI
            </h1>
            <p className="text-lg opacity-60 max-w-md relative z-10">
              Select a project from the sidebar or create a new session to start interacting with the agent.
            </p>
          </div>
        )}
      </main>
    </div>
  );
}
