-- Project Tuttwiler Database Schema
-- SQLite Database (MVP)
-- This schema supports the Mission Control dashboard and alert triage system

-- ============================================================================
-- ALERTS TABLE
-- ============================================================================
-- Stores all security alerts with their core information
CREATE TABLE IF NOT EXISTS alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Core Alert Information
    title TEXT NOT NULL,
    description TEXT,
    ai_summary TEXT,  -- AI-generated plain-English summary
    
    -- Timing Information
    detected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Alert Classification
    affected_function TEXT NOT NULL,  -- e.g., "Lab diagnostics", "Food safety"
    system_name TEXT,  -- e.g., "Controller X"
    impact_level TEXT NOT NULL CHECK(impact_level IN ('RED', 'YELLOW', 'GREEN')),
    impact_description TEXT,  -- e.g., "Direct Care Threat", "Service Continuity"
    
    -- Human Impact Index Scores (from design doc)
    human_safety_score INTEGER CHECK(human_safety_score >= 0 AND human_safety_score <= 5),
    accuracy_score INTEGER CHECK(accuracy_score >= 0 AND accuracy_score <= 5),
    dependency_score INTEGER CHECK(dependency_score >= 0 AND dependency_score <= 5),
    exploitability_score INTEGER CHECK(exploitability_score >= 0 AND exploitability_score <= 5),
    patch_status_score INTEGER CHECK(patch_status_score >= 0 AND patch_status_score <= 5),
    operational_exposure_score INTEGER CHECK(operational_exposure_score >= 0 AND operational_exposure_score <= 5),
    total_score REAL,  -- Calculated total score
    
    -- Alert Status
    status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'resolved', 'suppressed', 'escalated')),
    
    -- Relevance (Is This Us?)
    relevance TEXT CHECK(relevance IN ('yes', 'no', 'unsure')),
    
    -- CVE/Identifier
    cve_id TEXT,  -- e.g., "CVE-2024-1234"
    cve_url TEXT,
    
    -- Deduplication
    content_hash TEXT,  -- Hash of alert content for deduplication
    url_hash TEXT  -- Hash of source URLs for deduplication
);

-- ============================================================================
-- PROVENANCE TABLE
-- ============================================================================
-- Tracks source information and trust/verification status for each alert
CREATE TABLE IF NOT EXISTS provenance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alert_id INTEGER NOT NULL,
    
    -- Source Information
    source_name TEXT NOT NULL,  -- e.g., "Vendor bulletin (Siemens Medical)"
    source_type TEXT,  -- e.g., "vendor", "cisa", "cve", "community"
    source_url TEXT,
    
    -- Verification & Trust
    verified BOOLEAN NOT NULL DEFAULT 0,  -- True if verified source
    confidence TEXT CHECK(confidence IN ('High', 'Medium', 'Low')),
    tlp_marking TEXT CHECK(tlp_marking IN ('RED', 'AMBER', 'GREEN', 'WHITE', 'CLEAR')),
    
    -- Provenance Tracking
    origin_url TEXT,
    content_hash TEXT,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE CASCADE
);

-- ============================================================================
-- SAFE_ACTIONS TABLE
-- ============================================================================
-- Stores the safe action playbook steps for each alert
CREATE TABLE IF NOT EXISTS safe_actions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alert_id INTEGER NOT NULL,
    
    -- Action Details
    step_number INTEGER NOT NULL,
    action_text TEXT NOT NULL,
    action_type TEXT CHECK(action_type IN ('pre_check', 'do_not', 'action_today', 'escalation_trigger', 'monitoring', 'recovery')),
    
    -- Ordering
    display_order INTEGER NOT NULL,
    
    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE CASCADE
);

-- ============================================================================
-- NOTIFICATIONS TABLE
-- ============================================================================
-- Tracks user notifications for alerts
CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alert_id INTEGER NOT NULL,
    user_id TEXT NOT NULL DEFAULT 'default_user',  -- For MVP, using simple user ID
    
    -- Notification Status
    read_status BOOLEAN NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME,
    
    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE CASCADE
);

-- ============================================================================
-- DECISIONS TABLE
-- ============================================================================
-- Records user decisions (GO/HOLD/ESCALATE) for each alert
CREATE TABLE IF NOT EXISTS decisions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alert_id INTEGER NOT NULL,
    user_id TEXT NOT NULL DEFAULT 'default_user',
    
    -- Decision Information
    decision_type TEXT NOT NULL CHECK(decision_type IN ('GO', 'HOLD', 'ESCALATE')),
    decision_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Context for Decision
    score_breakdown TEXT,  -- JSON string with score details
    notes TEXT,  -- Optional user notes
    
    -- Relevance at time of decision
    relevance_at_decision TEXT CHECK(relevance_at_decision IN ('yes', 'no', 'unsure')),
    
    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE CASCADE
);

-- ============================================================================
-- AUDIT_LOGS TABLE
-- ============================================================================
-- Comprehensive audit trail for all actions and decisions
CREATE TABLE IF NOT EXISTS audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alert_id INTEGER,
    user_id TEXT NOT NULL DEFAULT 'default_user',
    
    -- Action Information
    action TEXT NOT NULL,  -- e.g., "decision_made", "alert_viewed", "relevance_changed"
    action_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Metadata (JSON string for flexibility)
    metadata TEXT,  -- JSON string with additional context
    
    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE SET NULL
);

-- ============================================================================
-- INDEXES for Performance
-- ============================================================================

-- Alerts indexes
CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status);
CREATE INDEX IF NOT EXISTS idx_alerts_impact_level ON alerts(impact_level);
CREATE INDEX IF NOT EXISTS idx_alerts_detected_at ON alerts(detected_at);
CREATE INDEX IF NOT EXISTS idx_alerts_total_score ON alerts(total_score DESC);

-- Provenance indexes
CREATE INDEX IF NOT EXISTS idx_provenance_alert_id ON provenance(alert_id);
CREATE INDEX IF NOT EXISTS idx_provenance_verified ON provenance(verified);

-- Safe actions indexes
CREATE INDEX IF NOT EXISTS idx_safe_actions_alert_id ON safe_actions(alert_id);
CREATE INDEX IF NOT EXISTS idx_safe_actions_display_order ON safe_actions(alert_id, display_order);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_alert_id ON notifications(alert_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read_status ON notifications(read_status);

-- Decisions indexes
CREATE INDEX IF NOT EXISTS idx_decisions_alert_id ON decisions(alert_id);
CREATE INDEX IF NOT EXISTS idx_decisions_user_id ON decisions(user_id);
CREATE INDEX IF NOT EXISTS idx_decisions_decision_type ON decisions(decision_type);
CREATE INDEX IF NOT EXISTS idx_decisions_timestamp ON decisions(decision_timestamp DESC);

-- Audit logs indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_alert_id ON audit_logs(alert_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(action_timestamp DESC);

-- ============================================================================
-- TRIGGERS for Automatic Updates
-- ============================================================================

-- Update updated_at timestamp when alert is modified
CREATE TRIGGER IF NOT EXISTS update_alerts_timestamp 
    AFTER UPDATE ON alerts
    FOR EACH ROW
BEGIN
    UPDATE alerts SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- ============================================================================
-- COMMENTS / DOCUMENTATION
-- ============================================================================
-- 
-- TABLE RELATIONSHIPS:
-- alerts (1) → (many) provenance
-- alerts (1) → (many) safe_actions
-- alerts (1) → (many) notifications
-- alerts (1) → (many) decisions
-- alerts (1) → (many) audit_logs
--
-- DATA FLOW:
-- 1. Alert is created in 'alerts' table
-- 2. Source information added to 'provenance' table
-- 3. Safe actions added to 'safe_actions' table
-- 4. Notification created in 'notifications' table
-- 5. User views alert, makes decision → recorded in 'decisions'
-- 6. All actions logged in 'audit_logs'
--
-- PRIORITY ORDERING:
-- Alerts should be sorted by:
-- 1. impact_level (RED > YELLOW > GREEN)
-- 2. total_score (descending)
-- 3. detected_at (descending - most recent first)
--
-- IMPACT LEVEL THRESHOLDS (from Human Impact Index):
-- RED: total_score >= 70 OR (human_safety_score >= 3 AND (exploitability_score >= 3 OR patch_status_score >= 4))
-- YELLOW: total_score 40-69 and no RED trigger conditions
-- GREEN: total_score < 40

