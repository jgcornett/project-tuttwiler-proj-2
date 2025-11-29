# Implementation Order for Project Tuttwiler Dashboard

## Phase 1: Foundation (Back-End First)

### **Step 1: Database Schema Design** ⭐ START HERE
**Why First:** Everything depends on the data structure. You can't build UI or APIs without knowing what data you're working with.

**Tasks:**
- Design database tables:
  - `alerts` table (id, title, description, timestamp, affected_function, impact_level, status)
  - `notifications` table (id, alert_id, user_id, read_status, created_at)
  - `provenance` table (alert_id, source_url, source_name, confidence, tlp, content_hash, timestamp)
  - `safe_actions` table (id, alert_id, step_number, action_text, action_type)
  - `decisions` table (id, alert_id, user_id, decision_type, timestamp, score_breakdown)
  - `audit_logs` table (id, alert_id, user_id, action, timestamp, metadata)
- Choose database (PostgreSQL, MySQL, SQLite for MVP)
- Create migration scripts
- **Deliverable:** Database schema diagram + migration files

**Time Estimate:** 2-3 hours

---

### **Step 2: Dummy Data Generation** 
**Why Second:** You need test data to build and test the front-end. Can't develop UI without seeing real data.

**Tasks:**
- Create seed data script
- Generate 10-15 sample alerts with:
  - Mix of RED/YELLOW/GREEN impact levels
  - Different affected functions (Lab diagnostics, Food safety, etc.)
  - Sample provenance data (CVE/NVD, CISA, Vendor sources)
  - Safe action playbooks (3-5 steps each)
  - Timestamps spanning a few days
- Populate all tables with realistic dummy data
- **Deliverable:** Database seeded with test data

**Time Estimate:** 1-2 hours

---

## Phase 2: Back-End API (Data Layer)

### **Step 3: Basic API Endpoints**
**Why Third:** Front-end needs APIs to fetch data. Build the data layer before the presentation layer.

**Tasks:**
- Set up API framework (Express.js, Flask, FastAPI, etc.)
- Create endpoints:
  - `GET /api/alerts` - List all alerts (with filters for status, impact_level)
  - `GET /api/alerts/:id` - Get single alert with full details
  - `GET /api/notifications` - Get user's notifications
  - `POST /api/decisions` - Record GO/HOLD/ESCALATE decision
- Return JSON matching the data structure
- **Deliverable:** Working API that returns dummy data

**Time Estimate:** 3-4 hours

---

### **Step 4: Alert Prioritization Logic**
**Why Fourth:** Need to sort/filter alerts by priority before displaying. Core business logic.

**Tasks:**
- Implement sorting: Highest priority first (RED > YELLOW > GREEN)
- Implement filtering: By impact level, by status (unread, active, resolved)
- Add "single-card focus" - only show top priority alert
- **Deliverable:** API returns alerts in correct priority order

**Time Estimate:** 1-2 hours

---

## Phase 3: Front-End Foundation (UI Structure)

### **Step 5: Mission Control Layout (Static)** ⭐ CRITICAL UI STEP
**Why Fifth:** This is the core UI. Build the structure first, then add interactivity.

**Tasks:**
- Create Mission Control page component
- Build layout matching prototype PDFs (`mission_control_full_big.pdf`):
  - Header with title area
  - Impact pill component (RED/YELLOW/GREEN badge)
  - Content sections (AI Summary, Sources, Safe Actions)
  - Decision buttons row (GO / HOLD / ESCALATE)
  - "Is this us?" checkbox
- Use static/hardcoded data first (don't connect to API yet)
- Match the visual design from prototype PDFs
- **Deliverable:** Static Mission Control page that looks like the prototype

**Time Estimate:** 4-6 hours

---

### **Step 6: Alert Card Component**
**Why Sixth:** Reusable component for displaying individual alerts. Needed for both full and simple views.

**Tasks:**
- Create AlertCard component
- Display fields:
  - Title + timestamp + affected function
  - Impact pill (color-coded RED/YELLOW/GREEN)
  - AI Summary section
  - Source & Confidence section
  - Safe Action Playbook (numbered list)
- Make it responsive
- **Deliverable:** Reusable AlertCard component

**Time Estimate:** 2-3 hours

---

## Phase 4: Integration (Connect Front-End to Back-End)

### **Step 7: Connect API to Front-End**
**Why Seventh:** Now that both sides exist, connect them together.

**Tasks:**
- Replace hardcoded data with API calls
- Fetch alerts from `GET /api/alerts`
- Display top priority alert in Mission Control
- Handle loading states
- Handle error states
- **Deliverable:** Mission Control displays real data from database

**Time Estimate:** 2-3 hours

---

### **Step 8: Decision Workflow (GO/HOLD/ESCALATE)**
**Why Eighth:** Core functionality - users need to make decisions. Build this after data is flowing.

**Tasks:**
- Add click handlers to GO/HOLD/ESCALATE buttons
- Call `POST /api/decisions` when user clicks
- Update UI to show decision was recorded
- Move to next alert after decision
- Log to audit_logs table
- **Deliverable:** Users can make decisions that are saved to database

**Time Estimate:** 2-3 hours

---

## Phase 5: Enhanced Features

### **Step 9: "Is This Us?" Relevance Filter**
**Why Ninth:** Important feature but not critical for MVP. Add after core workflow works.

**Tasks:**
- Add checkbox to Mission Control
- Store relevance status (affects us / not sure / no)
- Filter out "no" alerts from main view
- Update database schema if needed
- **Deliverable:** Users can mark alerts as not applicable

**Time Estimate:** 1-2 hours

---

### **Step 10: Notification System**
**Why Tenth:** Enhancement feature. Core dashboard works, now add notifications.

**Tasks:**
- Create notifications list/panel
- Show unread count badge
- Mark notifications as read
- Link notifications to alerts
- **Deliverable:** Notification system working

**Time Estimate:** 2-3 hours

---

### **Step 11: Human Impact Index Scoring (If Time Permits)**
**Why Eleventh:** Advanced feature. Can use simple impact levels (RED/YELLOW/GREEN) for MVP, add scoring later.

**Tasks:**
- Implement scoring algorithm from design docs
- Calculate scores based on 6 core factors + 3 modifiers
- Auto-assign impact levels based on thresholds
- Display score breakdown in UI
- **Deliverable:** Automated scoring system

**Time Estimate:** 4-6 hours (complex)

---

### **Step 12: Simple Card View (Mobile/Lite)**
**Why Twelfth:** Nice-to-have. Full Mission Control works first, then add simplified version.

**Tasks:**
- Create simplified card component
- Match `mission_control_card_simple.pdf` design
- Show only: Title, impact pill, 2 bullets, Schedule/Remind buttons
- Make responsive for mobile
- **Deliverable:** Simple card view for mobile/quick demos

**Time Estimate:** 2-3 hours

---

## Summary: Critical Path (MVP)

**Must-Have for MVP:**
1. ✅ Database Schema Design
2. ✅ Dummy Data Generation
3. ✅ Basic API Endpoints
4. ✅ Alert Prioritization Logic
5. ✅ Mission Control Layout (Static)
6. ✅ Alert Card Component
7. ✅ Connect API to Front-End
8. ✅ Decision Workflow (GO/HOLD/ESCALATE)

**Nice-to-Have (Add if time):**
9. "Is This Us?" Filter
10. Notification System
11. Human Impact Index Scoring
12. Simple Card View

---

## Recommended Tech Stack (Based on Design Docs)

**Back-End:**
- Database: PostgreSQL or SQLite (for MVP)
- API: Node.js/Express or Python/Flask
- ORM: Prisma, Sequelize, or SQLAlchemy

**Front-End:**
- Framework: React, Vue, or vanilla JS
- UI Library: Tailwind CSS, Material-UI, or Bootstrap
- State Management: Context API, Redux, or Zustand

**Key Files to Reference:**
- `03_Prototype/mission_control_full_big.pdf` - Full UI design
- `03_Prototype/mission_control_card_simple.pdf` - Simple UI design
- `02_Design & Architecture/human_impact_index.csv` - Scoring model
- `04_Operations/Safe_Action_Playbook_Example.pdf` - Playbook structure

---

## Parallel Work Opportunities

**Can Work Simultaneously:**
- Step 1 (Database) + Step 5 (UI Layout) - Different people
- Step 3 (API) + Step 6 (Alert Card) - Different people
- Step 7 (Integration) + Step 9 (Is This Us?) - Different people

**Must Be Sequential:**
- Step 1 → Step 2 → Step 3 (database dependencies)
- Step 5 → Step 7 (UI before integration)
- Step 7 → Step 8 (data flow before decisions)

---

## Testing Strategy

**After Each Step:**
- Step 1: Verify database tables created correctly
- Step 2: Verify dummy data looks realistic
- Step 3: Test API endpoints with Postman/curl
- Step 5: Visual check against prototype PDFs
- Step 7: Verify data displays correctly
- Step 8: Verify decisions save to database

**Final Integration Test:**
- User can see alert → Make decision → See next alert → Decisions logged

---

*This order prioritizes getting a working MVP first, then adding enhancements.*

