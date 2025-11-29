import React, { useState, useEffect } from 'react'
import './MissionControl.css'

// API Configuration
const API_URL = 'http://localhost:3001/api'

function MissionControl() {
  const [quietMode, setQuietMode] = useState(false)
  const [relevance, setRelevance] = useState(null)
  const [currentAlert, setCurrentAlert] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)
  const [successMessage, setSuccessMessage] = useState(null)

  // Fetch top priority alert from API
  useEffect(() => {
    fetchTopPriorityAlert()
  }, [])

  const fetchTopPriorityAlert = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await fetch(`${API_URL}/alerts/priority/top`)
      const data = await response.json()
      
      if (!response.ok) {
        throw new Error(data.error || 'Failed to fetch alert')
      }
      
      if (data.success && data.alert) {
        // Only update if it's a different alert
        if (!currentAlert || currentAlert.id !== data.alert.id) {
          setCurrentAlert(data.alert)
          // Set relevance from alert if available
          if (data.alert.relevance) {
            setRelevance(data.alert.relevance)
          } else {
            setRelevance(null)
          }
        }
      } else {
        // No alerts available
        setCurrentAlert(null)
        setRelevance(null)
      }
    } catch (err) {
      console.error('Error fetching alert:', err)
      setError(err.message || 'Failed to load alert')
    } finally {
      setLoading(false)
    }
  }

  const handleQuietModeToggle = () => {
    setQuietMode(!quietMode)
    
    // If quiet mode is ON, only show RED alerts
    // If turning quiet mode ON, refresh alerts to filter
    if (!quietMode) {
      // Quiet mode is being turned ON
      // Filter will be handled on next fetch
      fetchTopPriorityAlert()
    } else {
      // Quiet mode is being turned OFF, show all alerts
      fetchTopPriorityAlert()
    }
  }

  const handleRelevanceChange = (value) => {
    setRelevance(value)
  }

  const handleDecision = async (decisionType) => {
    if (!currentAlert || submitting) return
    
    try {
      setSubmitting(true)
      setSuccessMessage(null)
      setError(null)
      
      const response = await fetch(`${API_URL}/decisions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          alertId: currentAlert.id,
          decisionType: decisionType,
          userId: 'default_user',
          relevance: relevance,
          notes: null
        })
      })
      
      const data = await response.json()
      
      if (!response.ok) {
        throw new Error(data.error || 'Failed to record decision')
      }
      
      if (data.success) {
        // Show success message
        const decisionMessages = {
          'GO': 'Decision recorded: You will take action on this alert.',
          'HOLD': 'Decision recorded: Alert held for later review.',
          'ESCALATE': 'Decision recorded: Alert escalated to Tier-2.'
        }
        setSuccessMessage(decisionMessages[decisionType] || 'Decision recorded successfully')
        
        // Clear relevance selection
        setRelevance(null)
        
        // Wait a moment to show success message, then fetch next alert
        setTimeout(async () => {
          setSuccessMessage(null)
          // Clear current alert immediately so UI updates
          setCurrentAlert(null)
          setLoading(true)
          
          // Add a small delay to ensure backend has processed the decision
          await new Promise(resolve => setTimeout(resolve, 500))
          
          try {
            await fetchTopPriorityAlert()
          } catch (fetchError) {
            console.error('Error fetching next alert:', fetchError)
            setError('Failed to load next alert. Please refresh the page.')
          } finally {
            setSubmitting(false)
          }
        }, 1200)
      }
    } catch (err) {
      console.error('Error recording decision:', err)
      setError(`Failed to record decision: ${err.message}`)
      setSubmitting(false)
    }
  }

  // Loading state
  if (loading && !submitting) {
    return (
      <div className="mission-control">
        <header className="mission-control-header">
          <div className="header-left">
            <h1>Mission Control</h1>
          </div>
        </header>
        <div className="alert-card" style={{ textAlign: 'center', padding: '60px 20px' }}>
          <p>Loading alert...</p>
        </div>
      </div>
    )
  }

  // Error state
  if (error) {
    return (
      <div className="mission-control">
        <header className="mission-control-header">
          <div className="header-left">
            <h1>Mission Control</h1>
          </div>
        </header>
        <div className="alert-card" style={{ textAlign: 'center', padding: '60px 20px', color: '#dc3545' }}>
          <h3>Error loading alert</h3>
          <p>{error}</p>
          <button 
            onClick={fetchTopPriorityAlert}
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

  // No alerts available
  if (!currentAlert) {
    return (
      <div className="mission-control">
        <header className="mission-control-header">
          <div className="header-left">
            <h1>Mission Control</h1>
          </div>
          <div className="header-right">
            <div className="quiet-mode-toggle">
              <label>
                <input
                  type="checkbox"
                  checked={quietMode}
                  onChange={handleQuietModeToggle}
                />
                Quiet Mode: <span>{quietMode ? 'ON' : 'OFF'}</span>
              </label>
            </div>
          </div>
        </header>
        <div className="alert-card" style={{ textAlign: 'center', padding: '60px 20px' }}>
          <h2>No Active Alerts</h2>
          <p>All clear! No alerts require attention at this time.</p>
        </div>
      </div>
    )
  }

  // Normal state - show alert
  return (
    <div className="mission-control">
      {/* Header Section */}
      <header className="mission-control-header">
        <div className="header-left">
          <h1>Mission Control</h1>
        </div>
        <div className="header-right">
          <div className="quiet-mode-toggle">
            <label>
              <input
                type="checkbox"
                checked={quietMode}
                onChange={handleQuietModeToggle}
              />
              Quiet Mode: <span>{quietMode ? 'ON' : 'OFF'}</span>
            </label>
          </div>
        </div>
      </header>

      {/* Alert Card */}
      <div className="alert-card">
        {/* Alert Header */}
        <div className="alert-header">
          <h2 className="alert-title">{currentAlert.title}</h2>
          <div className="alert-meta">
            Detected {currentAlert.timestamp} • Affects: {currentAlert.affectedFunction}
          </div>
        </div>

        {/* Impact Pill */}
        <div className={`impact-pill impact-pill-${currentAlert.impactLevel.toLowerCase()}`}>
          <span className="impact-level">{currentAlert.impactLevel}</span>
          <span className="impact-description"> — {currentAlert.impactDescription}</span>
        </div>

        {/* Is This Us? Relevance Check */}
        <div className="relevance-check">
          <h3>Does this affect us?</h3>
          <div className="relevance-options">
            <label className="relevance-option">
              <input
                type="radio"
                name="relevance"
                value="yes"
                checked={relevance === 'yes'}
                onChange={() => handleRelevanceChange('yes')}
              />
              <span>We use {currentAlert.systemName || 'this system'} in production</span>
            </label>
            <label className="relevance-option">
              <input
                type="radio"
                name="relevance"
                value="no"
                checked={relevance === 'no'}
                onChange={() => handleRelevanceChange('no')}
              />
              <span>Not sure / No</span>
            </label>
          </div>
        </div>

        {/* AI Summary Section */}
        <div className="ai-summary-section">
          <h3>AI Summary</h3>
          <div className="ai-summary-content">
            <p>{currentAlert.aiSummary || currentAlert.description || 'No summary available.'}</p>
          </div>
        </div>

        {/* Source & Confidence Section */}
        <div className="sources-section">
          <h3>Source & Confidence</h3>
          {currentAlert.sources && currentAlert.sources.length > 0 ? (
            <>
              <ul className="sources-list">
                {currentAlert.sources.map((source, index) => (
                  <li key={index} className="source-item">
                    <span className="source-bullet">•</span>
                    <span className="source-name">{source.name}</span>
                    <span className={`source-status ${source.verified ? 'verified' : 'unverified'}`}>
                      {source.verified ? ' — Verified' : ' — Unverified'}
                    </span>
                  </li>
                ))}
              </ul>
              <div className="confidence-level">
                <strong>Confidence:</strong> {currentAlert.confidence || 'Unknown'}
              </div>
            </>
          ) : (
            <p>No source information available.</p>
          )}
        </div>

        {/* Safe Action Playbook Section */}
        <div className="safe-actions-section">
          <h3>Safe Action Playbook — Do This Today</h3>
          {currentAlert.safeActions && currentAlert.safeActions.length > 0 ? (
            <>
              <ol className="safe-actions-list">
                {currentAlert.safeActions.map((action, index) => (
                  <li key={index} className="safe-action-item">
                    {action}
                  </li>
                ))}
              </ol>
              <div className="safety-disclaimer">
                <p>
                  Written for regulated environments (clinical/GMP/food). 
                  No 'take offline' one-click actions.
                </p>
              </div>
            </>
          ) : (
            <p>No action items available for this alert.</p>
          )}
        </div>

        {/* Success Message */}
        {successMessage && (
          <div style={{
            padding: '16px',
            backgroundColor: '#d4edda',
            color: '#155724',
            borderRadius: '6px',
            marginBottom: '24px',
            border: '1px solid #c3e6cb',
            textAlign: 'center'
          }}>
            ✓ {successMessage}
          </div>
        )}

        {/* Decision Buttons */}
        <div className="decision-buttons">
          <button 
            className="decision-button decision-go"
            onClick={() => handleDecision('GO')}
            disabled={submitting || loading}
            style={{ opacity: submitting || loading ? 0.6 : 1, cursor: submitting || loading ? 'not-allowed' : 'pointer' }}
          >
            {submitting ? 'Processing...' : 'GO'}
          </button>
          <button 
            className="decision-button decision-hold"
            onClick={() => handleDecision('HOLD')}
            disabled={submitting || loading}
            style={{ opacity: submitting || loading ? 0.6 : 1, cursor: submitting || loading ? 'not-allowed' : 'pointer' }}
          >
            {submitting ? 'Processing...' : 'HOLD'}
          </button>
          <button 
            className="decision-button decision-escalate"
            onClick={() => handleDecision('ESCALATE')}
            disabled={submitting || loading}
            style={{ opacity: submitting || loading ? 0.6 : 1, cursor: submitting || loading ? 'not-allowed' : 'pointer' }}
          >
            {submitting ? 'Processing...' : 'ESCALATE'}
          </button>
        </div>
      </div>
    </div>
  )
}

export default MissionControl
