import React, { useState } from 'react';
import { FolderPlus, Folder, X } from 'lucide-react';

interface SessionNavProps {
  sessions: { id: string, path: string }[];
  activeSessionId: string | null;
  onSelectSession: (id: string) => void;
  onCreateSession: (path: string) => void;
}

export default function SessionNav({ sessions, activeSessionId, onSelectSession, onCreateSession }: SessionNavProps) {
  const [pathInput, setPathInput] = useState('');

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (pathInput.trim()) {
      onCreateSession(pathInput.trim());
      setPathInput('');
    }
  };

  return (
    <aside className="w-72 h-full glass m-4 mr-0 flex flex-col p-4 gap-6 border-r-0">
      <div className="flex items-center gap-2 px-2 mb-4">
        <div className="w-8 h-8 lune-gradient rounded-lg flex items-center justify-center font-bold text-white">
          OC
        </div>
        <span className="font-bold text-lg tracking-tight">Sessions</span>
      </div>

      <form onSubmit={handleCreate} className="flex flex-col gap-2 p-2 bg-white/5 rounded-xl border border-white/10">
        <input
          type="text"
          placeholder="C:\path\to\project"
          className="bg-transparent text-xs p-2 outline-none border-b border-white/10 focus:border-[#C8A8E9] transition-colors"
          value={pathInput}
          onChange={(e) => setPathInput(e.target.value)}
        />
        <button
          type="submit"
          className="flex items-center justify-center gap-2 bg-white/10 hover:bg-white/20 p-2 rounded-lg text-xs transition-all"
        >
          <FolderPlus size={14} />
          New Session
        </button>
      </form>

      <div className="flex-1 overflow-y-auto flex flex-col gap-2 pr-2 custom-scrollbar">
        {sessions.map(s => (
          <button
            key={s.id}
            onClick={() => onSelectSession(s.id)}
            className={`flex items-center gap-3 p-3 rounded-xl text-left transition-all group ${
              activeSessionId === s.id
                ? 'bg-white/10 ring-1 ring-white/20 shadow-xl'
                : 'hover:bg-white/5 opacity-60 hover:opacity-100'
            }`}
          >
            <Folder size={16} className={activeSessionId === s.id ? 'text-[#C8A8E9]' : 'text-white/40'} />
            <div className="flex-1 overflow-hidden">
              <div className="text-xs font-medium truncate">{s.id}</div>
              <div className="text-[10px] opacity-40 truncate">{s.path}</div>
            </div>
          </button>
        ))}
      </div>
    </aside>
  );
}
