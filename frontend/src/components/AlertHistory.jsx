import React, { useState, useEffect } from 'react'
import './MissionControl.css'

const API_URL = 'http://localhost:3001/api'

function AlertHistory() {
  const [alerts, setAlerts] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchAlertHistory()
  }, [])

  const fetchAlertHistory = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await fetch(`${API_URL}/alerts/history`)
      const data = await response.json()
      
      if (!response.ok) {
        throw new Error(data.error || 'Failed to fetch alert history')
      }
      
      if (data.success) {
        setAlerts(data.alerts || [])
      }
    } catch (err) {
      console.error('Error fetching alert history:', err)
      setError(err.message || 'Failed to load alert history')
    } finally {
      setLoading(false)
    }
  }

  const getImpactColor = (level) => {
    switch (level) {
      case 'RED': return '#dc3545'
      case 'YELLOW': return '#ffc107'
      case 'GREEN': return '#28a745'
      default: return '#6c757d'
    }
  }

  const getDecisionColor = (decision) => {
    switch (decision) {
      case 'GO': return '#28a745'
      case 'HOLD': return '#ffc107'
      case 'ESCALATE': return '#dc3545'
      default: return '#6c757d'
    }
  }

  if (loading) {
    return (
      <div className="mission-control">
        <header className="mission-control-header">
          <div className="header-left">
            <h1>Alert History</h1>
          </div>
        </header>
        <div className="alert-card" style={{ textAlign: 'center', padding: '60px 20px' }}>
          <p>Loading alert history...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="mission-control">
        <header className="mission-control-header">
          <div className="header-left">
            <h1>Alert History</h1>
          </div>
        </header>
        <div className="alert-card" style={{ textAlign: 'center', padding: '60px 20px', color: '#dc3545' }}>
          <h3>Error loading history</h3>
          <p>{error}</p>
          <button 
            onClick={fetchAlertHistory}
            style={{ 
              marginTop: '20px', 
              padding: '10px 20px', 
              backgroundColor: '#007bff', 
              color: 'white', 
              border: 'none', 
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            Retry
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="mission-control">
      <header className="mission-control-header">
        <div className="header-left">
          <h1>Alert History</h1>
          <p style={{ margin: '4px 0 0 0', fontSize: '14px', color: '#666' }}>
            View all alerts and their decisions
          </p>
        </div>
      </header>

      {alerts.length === 0 ? (
        <div className="alert-card" style={{ textAlign: 'center', padding: '60px 20px' }}>
          <p>No alert history available.</p>
        </div>
      ) : (
        <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
          {alerts.map((alert) => (
            <div 
              key={alert.id} 
              className="alert-card" 
              style={{ 
                marginBottom: '24px',
                borderLeft: `4px solid ${getImpactColor(alert.impactLevel)}`
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
                <div style={{ flex: 1 }}>
                  <h2 className="alert-title" style={{ marginBottom: '8px' }}>
                    {alert.title}
                  </h2>
                  <div className="alert-meta">
                    Detected {alert.timestamp} on {alert.date} • Affects: {alert.affectedFunction}
                  </div>
                </div>
                
                {/* Impact Level Badge */}
                <div 
                  style={{
                    padding: '8px 16px',
                    borderRadius: '6px',
                    color: alert.impactLevel === 'YELLOW' ? '#000' : 'white',
                    backgroundColor: getImpactColor(alert.impactLevel),
                    fontWeight: 'bold',
                    fontSize: '14px',
                    marginLeft: '16px'
                  }}
                >
                  {alert.impactLevel}
                </div>
              </div>

              {/* Decision Badge */}
              {alert.decisionType && (
                <div style={{ marginBottom: '16px' }}>
                  <span
                    style={{
                      display: 'inline-block',
                      padding: '6px 12px',
                      borderRadius: '4px',
                      color: alert.decisionType === 'HOLD' ? '#000' : 'white',
                      backgroundColor: getDecisionColor(alert.decisionType),
                      fontWeight: '500',
                      fontSize: '13px',
                      marginRight: '12px'
                    }}
                  >
                    Decision: {alert.decisionType}
                  </span>
                  {alert.decisionTimestamp && (
                    <span style={{ fontSize: '13px', color: '#666' }}>
                      on {new Date(alert.decisionTimestamp).toLocaleString()}
                    </span>
                  )}
                </div>
              )}

              {/* Alert Details */}
              <div style={{ marginTop: '16px' }}>
                {alert.aiSummary && (
                  <div style={{ marginBottom: '12px' }}>
                    <strong>Summary:</strong> {alert.aiSummary}
                  </div>
                )}
                
                <div style={{ display: 'flex', gap: '24px', fontSize: '14px', color: '#666' }}>
                  <div>
                    <strong>Status:</strong> {alert.status}
                  </div>
                  {alert.totalScore !== null && (
                    <div>
                      <strong>Score:</strong> {alert.totalScore.toFixed(1)}
                    </div>
                  )}
                  {alert.relevance && (
                    <div>
                      <strong>Relevance:</strong> {alert.relevance}
                    </div>
                  )}
                </div>
              </div>

              {!alert.decisionType && (
                <div style={{ 
                  marginTop: '16px', 
                  padding: '12px', 
                  backgroundColor: '#fff3cd', 
                  borderRadius: '4px',
                  fontSize: '14px',
                  color: '#856404'
                }}>
                  ⚠️ No decision made yet
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default AlertHistory

