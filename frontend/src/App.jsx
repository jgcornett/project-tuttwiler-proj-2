import React, { useState } from 'react'
import MissionControl from './components/MissionControl'
import AlertHistory from './components/AlertHistory'
import './App.css'

function App() {
  const [view, setView] = useState('current') // 'current' or 'history'

  return (
    <div className="App">
      {/* Navigation Tabs */}
      <div style={{
        position: 'sticky',
        top: 0,
        backgroundColor: '#fff',
        borderBottom: '2px solid #e0e0e0',
        zIndex: 100,
        padding: '12px 24px',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
      }}>
        <div style={{ 
          maxWidth: '1200px', 
          margin: '0 auto', 
          display: 'flex', 
          gap: '12px' 
        }}>
          <button
            onClick={() => setView('current')}
            style={{
              padding: '10px 20px',
              fontSize: '16px',
              fontWeight: 'bold',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              backgroundColor: view === 'current' ? '#007bff' : '#f0f0f0',
              color: view === 'current' ? 'white' : '#333',
              transition: 'all 0.2s'
            }}
          >
            Current Alert
          </button>
          <button
            onClick={() => setView('history')}
            style={{
              padding: '10px 20px',
              fontSize: '16px',
              fontWeight: 'bold',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              backgroundColor: view === 'history' ? '#007bff' : '#f0f0f0',
              color: view === 'history' ? 'white' : '#333',
              transition: 'all 0.2s'
            }}
          >
            Alert History
          </button>
        </div>
      </div>

      {/* Render Current View */}
      {view === 'current' ? <MissionControl /> : <AlertHistory />}
    </div>
  )
}

export default App
