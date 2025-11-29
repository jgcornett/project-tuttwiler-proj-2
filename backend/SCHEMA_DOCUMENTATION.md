# Database Schema Documentation

## Overview

This document explains the database schema for Project Tuttwiler's Mission Control dashboard.

## Entity Relationship Diagram (Text)

```
┌─────────────────────────────────────────────────────────────┐
│                        ALERTS                                │
├─────────────────────────────────────────────────────────────┤
│ id (PK)                                                     │
│ title                                                        │
│ description                                                  │
│ ai_summary                                                   │
│ detected_at, created_at, updated_at                         │
│ affected_function                                            │
│ system_name                                                  │
│ impact_level (RED/YELLOW/GREEN)                             │
│ impact_description                                           │
│ human_safety_score, accuracy_score, ... (0-5)               │
│ total_score                                                  │
│ status (active/resolved/suppressed/escalated)               │
│ relevance (yes/no/unsure)                                    │
│ cve_id, cve_url                                              │
│ content_hash, url_hash                                       │
└─────────────────────────────────────────────────────────────┘
         │
         │ 1
         │
         │ *
         ├──────────────────────────────────────────────────────┐
         │                                                      │
         │ *                                                   │ *
         │                                                      │
┌────────▼──────────┐                                  ┌───────▼──────────┐
│   PROVENANCE      │                                  │  SAFE_ACTIONS    │
├───────────────────┤                                  ├──────────────────┤
│ id (PK)           │                                  │ id (PK)          │
│ alert_id (FK)     │                                  │ alert_id (FK)    │
│ source_name       │                                  │ step_number      │
│ source_type       │                                  │ action_text      │
│ source_url        │                                  │ action_type      │
│ verified          │                                  │ display_order    │
│ confidence        │                                  └──────────────────┘
│ tlp_marking       │
│ origin_url        │
│ content_hash      │
│ timestamp         │
└───────────────────┘
         │
         │ 1
         │
         │ *
         ├──────────────────────────────────────────────────────┐
         │                                                      │
         │ *                                                   │ *
         │                                                      │
┌────────▼──────────┐                                  ┌───────▼──────────┐
│ NOTIFICATIONS     │                                  │   DECISIONS      │
├───────────────────┤                                  ├──────────────────┤
│ id (PK)           │                                  │ id (PK)          │
│ alert_id (FK)     │                                  │ alert_id (FK)    │
│ user_id           │                                  │ user_id          │
│ read_status       │                                  │ decision_type    │
│ created_at        │                                  │ (GO/HOLD/ESCALATE)│
│ read_at           │                                  │ decision_timestamp│
└───────────────────┘                                  │ score_breakdown  │
                                                       │ notes            │
                                                       │ relevance_at_decision│
                                                       └──────────────────┘
                                                                 │
                                                                 │ 1
                                                                 │
                                                                 │ *
                                                       ┌─────────▼──────────┐
                                                       │   AUDIT_LOGS       │
                                                       ├────────────────────┤
                                                       │ id (PK)            │
                                                       │ alert_id (FK)      │
                                                       │ user_id            │
                                                       │ action             │
                                                       │ action_timestamp   │
                                                       │ metadata (JSON)    │
                                                       └────────────────────┘
```

## Table Descriptions

### 1. `alerts` - Main Alert Table

**Purpose:** Stores all security alerts with their complete information.

**Key Fields:**
- `id` - Unique identifier
- `title` - Alert title (e.g., "Critical: Controller X firmware vuln")
- `impact_level` - RED, YELLOW, or GREEN
- `total_score` - Calculated Human Impact Index score
- `status` - Current status (active, resolved, suppressed, escalated)
- `affected_function` - What system/process is affected
- `detected_at` - When the alert was detected

**Relationships:**
- One alert has many provenance records (sources)
- One alert has many safe_actions (playbook steps)
- One alert has many notifications
- One alert has many decisions

---

### 2. `provenance` - Source Tracking

**Purpose:** Tracks where alerts came from and verifies their trustworthiness.

**Key Fields:**
- `alert_id` - Links to the alert
- `source_name` - Name of the source (e.g., "CISA advisory")
- `verified` - Boolean: Is this a trusted source?
- `confidence` - High, Medium, or Low
- `source_url` - URL to the original source

**Example Sources:**
- CVE/NVD (canonical CVE feed) - Verified, High confidence
- CISA/CERT advisories - Verified, High confidence
- Vendor bulletins (Siemens, GE, Abbott) - Verified, High confidence
- Community reports - Unverified, Low confidence

---

### 3. `safe_actions` - Action Playbook Steps

**Purpose:** Stores the numbered safe action steps for each alert.

**Key Fields:**
- `alert_id` - Links to the alert
- `step_number` - Step number (1, 2, 3, etc.)
- `action_text` - The actual action text
- `display_order` - Order to display steps

**Action Types:**
- `pre_check` - Things to check before acting
- `do_not` - Actions to avoid
- `action_today` - Actions to take immediately
- `escalation_trigger` - When to escalate
- `monitoring` - Monitoring steps

**Example:**
```
Step 1: "Do not power-cycle during active runs."
Step 2: "Restrict Controller X network access to required systems only."
Step 3: "Log abnormal temps/restarts; escalate if observed."
```

---

### 4. `notifications` - User Notifications

**Purpose:** Tracks which users have been notified about alerts.

**Key Fields:**
- `alert_id` - Which alert
- `user_id` - Which user
- `read_status` - Has the user read it?
- `created_at` - When notification was created

---

### 5. `decisions` - User Decisions

**Purpose:** Records all GO/HOLD/ESCALATE decisions made by users.

**Key Fields:**
- `alert_id` - Which alert
- `user_id` - Who made the decision
- `decision_type` - GO, HOLD, or ESCALATE
- `decision_timestamp` - When the decision was made
- `score_breakdown` - JSON with score details
- `relevance_at_decision` - Was it relevant at decision time?

**Decision Types:**
- **GO** - "I'll take this action" (user will follow playbook)
- **HOLD** - "I'll handle this later" (defer)
- **ESCALATE** - "Send to Tier-2 / Bio-ISAC" (needs expert help)

---

### 6. `audit_logs` - Audit Trail

**Purpose:** Complete audit trail of all actions for compliance.

**Key Fields:**
- `alert_id` - Related alert (can be NULL for system actions)
- `user_id` - Who performed the action
- `action` - What action was taken
- `metadata` - JSON string with additional context
- `action_timestamp` - When it happened

**Example Actions:**
- `decision_made`
- `alert_viewed`
- `relevance_changed`
- `alert_escalated`

---

## Data Flow Example

1. **New Alert Created:**
   - Insert into `alerts` table with impact_level, scores, etc.
   - Status: `active`

2. **Add Sources:**
   - Insert multiple rows into `provenance` table
   - Link to alert_id

3. **Add Safe Actions:**
   - Insert numbered steps into `safe_actions` table
   - Link to alert_id

4. **Create Notification:**
   - Insert into `notifications` table
   - Read_status: `false`

5. **User Views Alert:**
   - Log action in `audit_logs`

6. **User Makes Decision:**
   - Insert into `decisions` table
   - Log action in `audit_logs`
   - Update `alerts.status` if needed

---

## Query Examples

### Get Top Priority Alert (for Mission Control)

```sql
SELECT * FROM alerts
WHERE status = 'active'
ORDER BY 
    CASE impact_level
        WHEN 'RED' THEN 1
        WHEN 'YELLOW' THEN 2
        WHEN 'GREEN' THEN 3
    END,
    total_score DESC,
    detected_at DESC
LIMIT 1;
```

### Get Alert with All Related Data

```sql
SELECT 
    a.*,
    GROUP_CONCAT(DISTINCT p.source_name) as sources,
    GROUP_CONCAT(sa.action_text ORDER BY sa.display_order) as actions
FROM alerts a
LEFT JOIN provenance p ON a.id = p.alert_id
LEFT JOIN safe_actions sa ON a.id = sa.alert_id
WHERE a.id = ?
GROUP BY a.id;
```

### Get User's Unread Notifications

```sql
SELECT n.*, a.title, a.impact_level
FROM notifications n
JOIN alerts a ON n.alert_id = a.id
WHERE n.user_id = ? AND n.read_status = 0
ORDER BY n.created_at DESC;
```

---

## Human Impact Index Scoring

The `alerts` table stores the 6 core factor scores (0-5 scale):
- `human_safety_score` (weight ×3.0)
- `accuracy_score` (weight ×2.0)
- `dependency_score` (weight ×2.0)
- `exploitability_score` (weight ×2.0)
- `patch_status_score` (weight ×1.5)
- `operational_exposure_score` (weight ×1.5)

The `total_score` field stores the calculated total.

**Thresholds:**
- **RED:** total_score ≥ 70 OR (human_safety_score ≥ 3 AND (exploitability_score ≥ 3 OR patch_status_score ≥ 4))
- **YELLOW:** total_score 40-69 (and no RED conditions)
- **GREEN:** total_score < 40

---

## Indexes

Indexes are created on frequently queried fields:
- `alerts.status`, `alerts.impact_level`, `alerts.detected_at`
- `provenance.alert_id`, `provenance.verified`
- `safe_actions.alert_id`, `safe_actions.display_order`
- `notifications.user_id`, `notifications.read_status`
- `decisions.alert_id`, `decisions.user_id`, `decisions.decision_type`
- `audit_logs.alert_id`, `audit_logs.user_id`, `audit_logs.action_timestamp`

---

## Notes for MVP

- Using SQLite (simple, file-based, no server needed)
- `user_id` is currently a simple TEXT field (can be upgraded later)
- `metadata` and `score_breakdown` are stored as JSON strings (can parse with JSON library)
- Timestamps use SQLite's DATETIME type
- Foreign keys are defined but SQLite foreign key constraints need to be enabled

