# Project Tuttwiler - Backend

## Database Schema

This directory contains the database schema and setup for Project Tuttwiler.

### Schema Overview

The database uses **SQLite** for the MVP (easiest setup, no separate server needed).

#### Tables:

1. **`alerts`** - Core alert information
   - Stores alert details, impact levels, scores, status
   - Primary table for the Mission Control dashboard

2. **`provenance`** - Source tracking and verification
   - Links to alerts, stores source URLs, verification status
   - Tracks confidence levels and TLP markings

3. **`safe_actions`** - Safe Action Playbook steps
   - Numbered action steps for each alert
   - Supports different action types (pre-checks, do-nots, actions, etc.)

4. **`notifications`** - User notifications
   - Tracks which users have been notified about alerts
   - Read/unread status

5. **`decisions`** - User decisions (GO/HOLD/ESCALATE)
   - Records all triage decisions
   - Links to alerts and users

6. **`audit_logs`** - Complete audit trail
   - Logs all actions and changes
   - For compliance and troubleshooting

### Setup Instructions

#### Option 1: Using SQLite Command Line

```bash
cd backend
sqlite3 tuttwiler.db < schema.sql
```

#### Option 2: Using Node.js/Python Script

(Will be created in next steps)

### Database File

The SQLite database will be created as `tuttwiler.db` in the backend directory.

### Next Steps

1. ✅ Database schema designed
2. ⏭️ Create seed data script (Step 2)
3. ⏭️ Set up API server (Step 3)

