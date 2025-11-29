import React, { useState } from 'react'
import './MissionControl.css'

function MissionControl() {
  // Hardcoded dummy data for Step 1
  const [quietMode, setQuietMode] = useState(false)
  const [relevance, setRelevance] = useState(null)

  // Sample alert data (hardcoded for now)
  const currentAlert = {
    id: 1,
    title: "Critical: Controller X firmware vuln (no patch)",
    timestamp: "14:32",
    date: "Today",
    affectedFunction: "Lab diagnostics",
    impactLevel: "RED",
    impactDescription: "Direct Care Threat",
    aiSummary: "Vulnerability in Controller X may allow remote changes to calibration. No vendor patch yet; mitigation required to protect diagnostic accuracy.",
    sources: [
      { name: "Vendor bulletin (Siemens Medical)", verified: true },
      { name: "CISA advisory", verified: true },
      { name: "Community report", verified: false }
    ],
    confidence: "High",
    safeActions: [
      "Do not power-cycle during active runs.",
      "Restrict Controller X network access to required systems only.",
      "Log abnormal temps/restarts; escalate if observed."
    ],
    systemName: "Controller X"
  }

  const handleQuietModeToggle = () => {
    setQuietMode(!quietMode)
  }

  const handleRelevanceChange = (value) => {
    setRelevance(value)
  }

  const handleDecision = (decisionType) => {
    // Placeholder for Step 4 - will connect to API later
    console.log(`Decision made: ${decisionType} for alert ${currentAlert.id}`)
    alert(`Decision recorded: ${decisionType}`)
  }

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
              <span>We use {currentAlert.systemName} in production</span>
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
            <p>{currentAlert.aiSummary}</p>
          </div>
        </div>

        {/* Source & Confidence Section */}
        <div className="sources-section">
          <h3>Source & Confidence</h3>
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
            <strong>Confidence:</strong> {currentAlert.confidence}
          </div>
        </div>

        {/* Safe Action Playbook Section */}
        <div className="safe-actions-section">
          <h3>Safe Action Playbook — Do This Today</h3>
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
        </div>

        {/* Decision Buttons */}
        <div className="decision-buttons">
          <button 
            className="decision-button decision-go"
            onClick={() => handleDecision('GO')}
          >
            GO
          </button>
          <button 
            className="decision-button decision-hold"
            onClick={() => handleDecision('HOLD')}
          >
            HOLD
          </button>
          <button 
            className="decision-button decision-escalate"
            onClick={() => handleDecision('ESCALATE')}
          >
            ESCALATE
          </button>
        </div>
      </div>
    </div>
  )
}

export default MissionControl

