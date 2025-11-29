# Project Tuttwiler - Detailed Design Document Analysis

## Executive Summary

**Project Name:** Project Tuttwiler — Tier-1 Triage MVP

**Problem Statement:**
Small bio/health/food operators (rural hospitals, labs, food processors) are overwhelmed by cybersecurity and biosecurity alerts. They lack time to interpret alerts, don't know which apply to them, can't assess real-world severity, and don't know what safe action to take immediately.

**Solution:** A triage assistant that:
- Ingests security signals
- Ranks by human impact (not just technical CVSS scores)
- Delivers one clear action at a time
- Goal: Fewer, smarter, safer decisions for under-resourced teams

**Target User:**
Overworked technical lead at small but critical operations:
- Rural hospital IT admin
- Food safety plant supervisor
- Diagnostics lab manager
- Responsible for uptime, safety, compliance
- No 24/7 SOC
- Needs: (1) Know if threat affects them, (2) Understand severity in human terms, (3) Know safe first step

---

## Core Features (7 Features)

### 1. Mission Control View
- **Purpose:** Reduce cognitive load; one decisive card at a time
- **Components:**
  - Title + timestamp + affected function (e.g., "Lab diagnostics")
  - Impact pill (RED/YELLOW/GREEN)
  - AI Summary + Source & Confidence
  - Safe Action Playbook (3-5 steps)
  - Decision row: GO / HOLD / ESCALATE (logs choice + packages context)
- **Variants:**
  - Full Screen: Complete mission control interface
  - Simple Card (Lite): Single alert card for quick demos and mobile

### 2. Human Impact Index (Scoring Model)
**Goal:** Prioritize by human and operational impact for small operators

**Core Factors (0-5 scale × weights):**
1. **Human Safety Impact (×3.0)** - Highest weight
   - 0=None → 5=Certain/ongoing harm
   - Potential for injury, mis-treatment, contamination, loss of life

2. **Clinical/Quality Accuracy (×2.0)**
   - 0=None → 5=Proven error risk
   - Risk of incorrect readings/results (e.g., calibration drift)

3. **Dependency & Substitutability (×2.0)**
   - 0=Easily replaced → 4=Sole-source/no backup
   - How replaceable is the affected system/process

4. **Exploitability / Activity (×2.0)**
   - 0=Theoretical → 5=Active in wild
   - Ease and likelihood of exploit; evidence of active exploitation

5. **Patch / Remediation Status (×1.5)**
   - 0=Patched → 5=Won't fix
   - Availability/timeliness of patch or compensating controls

6. **Operational Exposure (×1.5)**
   - 0=Isolated → 5=Internet-facing
   - Network/physical exposure; segmentation

**Context Modifiers (add/subtract):**
- **Scale/Reach:** -5 to +5 (people/units affected)
- **Time Sensitivity:** -5 to +5 (golden-hour, cold-chain, deadlines)
- **Source Confidence:** -10 (low) to +0 (high) - Trust in provenance

**Formula:**
```
Total = Σ(score × weight) + Σ(modifiers)
Reference max (pre-modifiers) ≈ 60
```

**Thresholds:**
- **RED (Escalate):** Total ≥ 70 OR (Human Safety ≥ 3 AND (Exploitability ≥ 3 OR Patch status ≥ 4))
- **YELLOW (Monitor/Plan):** Total 40–69 and no RED trigger conditions
- **GREEN (Informational):** Total < 40

**Worked Examples:**
1. **Lab Controller vuln, no patch: RED**
   - Scores: Human Safety=5, Accuracy=4, Dependency=4, Exploitability=3, Patch=4, Exposure=3
   - Modifiers: Scale/Reach=2, Time=3, Confidence=0
   - Action: Isolate + log + Tier-2 escalation

2. **Vendor patch available within 72h: YELLOW**
   - Scores: Human Safety=2, Accuracy=2, Dependency=3, Exploitability=2, Patch=2, Exposure=2
   - Modifiers: Scale/Reach=1, Time=1, Confidence=0
   - Action: Schedule patch window; notify stakeholders

3. **Kiosk UI library outdated (non-clinical): GREEN**
   - Scores: Human Safety=0, Accuracy=0, Dependency=1, Exploitability=2, Patch=1, Exposure=1
   - Modifiers: All 0
   - Action: Track and patch in normal cycle

### 3. Safe Action Playbooks
- Short, plain-language steps
- Safe for regulated environments (clinical/GMP/food)
- **Critical constraint:** No "one-click shutdown" actions
- Favor isolation, monitoring, compensating controls first
- Includes: Pre-checks, Do NOT actions, Actions for today, Escalation triggers, Monitoring steps

### 4. Source Provenance / Trust Ledger
- **Allowlist sources:**
  - CVE/NVD (canonical CVE feed)
  - CISA/CERT advisories
  - Vendor/OEM security portals (Siemens, GE, Abbott, etc.)
  - National/International CERTs (US-CERT, CERT-EU, ACSC)
  - FDA/EMA notices
- **Every alert includes:**
  - Origin URL
  - Timestamp
  - TLP (Traffic Light Protocol) marking
  - Content hash
  - Confidence tag
- **Denylist:** Known spoofers and unverified sources
- **Unverified tips:** Quarantined for Tier-2 review; never auto-escalated

### 5. "Is This Us?" Relevance Filter
- Quick local applicability check
- Suppresses non-applicable noise
- Manual checkbox: "We use Controller X in production" / "Not sure / No"
- Future: Automated asset inventory correlation

### 6. Tier-2 Escalation Workflow
- One-click package to Bio-ISAC
- Includes context and audit trail
- Bundles alert, environment context, and logs
- For RED alerts or when operator needs expert support

### 7. Quiet Mode / Fatigue Guard
- Only human-safety (RED) alerts can break through
- During protected windows
- Reduces alert fatigue
- Single-card focus; dedupe by CVE/URL

---

## Architecture & Data Flow

**Pipeline:**
```
Ingest → Normalize/Dedupe → AI Assist (Summarize/Score) → Human Triage → Action/Escalate → Audit
```

### Ingest & Normalize
**Sources:**
- CVE/NVD
- CISA/CERT
- Vendor Bulletins
- OEM Notices
- Sector Newsletters
- Ransomware Feeds

**Validation Steps:**
- Hash/URL dedupe
- Source allowlist/denylist
- TLP tag
- Confidence score
- Poisoning/spoof checks (domain/verbatim match)
- Unverified → queue for Tier-2 validation

### AI Assist + Human-in-the-Loop Triage
- **AI:** Summarizes advisories; proposes priority via Human Impact Index
- **Human:** Confirms relevance ("Is this us?"), adjusts score, chooses GO / HOLD / ESCALATE

### Actioning & Escalation
- Apply Safe Action Playbook
- Quiet Mode policy
- Notify stakeholders
- Escalate to Bio-ISAC Tier-2 with context
- Create audit/event log

---

## Risk / Trust Model

### 1. Source Provenance & Integrity
- Maintain allowlist (CVE/NVD, CISA/CERT, vendor/OEM) and denylist for spoofers
- Record provenance: origin URL, timestamp, TLP, hash, confidence score
- Detect poisoning/spoofing: domain verification, signature/PGP where available
- Unverified tips → Tier-2 validation queue; never auto-escalate

### 2. User Verification (Lightweight)
- Invitation or referral-based onboarding
- Organization email and role attestation
- Optional backchannel thumbs-up from trusted partners
- Risk-based access: sensitive guidance visible only to verified operators

### 3. AI Safety & Human Oversight
- AI summarizes and proposes score; humans confirm/adjust
- Guardrails: instruction tuning against "unsafe actions" (no one-click shutdowns)
- Prompt-injection tests
- Log AI outputs and human overrides for error analysis
- Denylist of unsafe recommendation phrases

### 4. Alert Fatigue & Notification Hygiene
- Mission-control single-card view
- Limit concurrent active alerts to top few
- Quiet Mode: only RED alerts break through protected windows
- Suppression: duplicates, non-applicable alerts, low-confidence sources

### 5. Auditability & Governance
- Every GO/HOLD/ESCALATE timestamped with user ID, score breakdown, provenance receipt
- Tier-2 escalation packages alert, environment context, logs
- Periodic review: sample AI summaries, false positives/negatives, notification break-throughs

---

## Prototype Screens

### Mission Control — Full Screen
**Components:**
- Title + timestamp + affected function
- Impact pill (RED/YELLOW/GREEN)
- AI Summary (proposed) + Source & Confidence
- Safe Action Playbook (3–5 steps)
- Decision row: GO / HOLD / ESCALATE
- "Is this us?" checkbox

**Example (RED Alert):**
- Title: "Critical: Controller X firmware vuln (no patch)"
- Affects: Lab diagnostics
- Impact: RED — Direct Care Threat
- AI Summary: "Vulnerability in Controller X may allow remote changes to calibration. No vendor patch yet; mitigation required to protect diagnostic accuracy."
- Sources: Vendor bulletin (Siemens Medical) — Verified, CISA advisory — Verified
- Safe Actions:
  1. Do not power-cycle during active runs
  2. Restrict Controller X network access to required systems only
  3. Log abnormal temps/restarts; escalate if observed

### Mission Control — Simple Card (Lite)
- Single alert card
- Title, subline, impact pill, 2 bullets
- Schedule / Remind buttons
- For quick demos and mobile

---

## Safe Action Playbooks

### Template Structure
- Alert Title
- Date/Time
- System/Asset
- Environment (clinical/GMP/food)
- Impact Level (R/Y/G)
- TLP
- Summary (1–2 sentences)
- Pre-checks
- Do NOT actions
- Actions — Do This Today
- Escalation — When to Call Tier-2
- Monitoring & Evidence to Capture
- Recovery/Verification Steps
- Audit Log (who/what/when)

### Example: No-patch Critical Vulnerability
**Scenario:** Lab Controller X firmware vulnerability, no patch available

**Pre-checks:**
- Confirm device is actively used in clinical/production workflow
- Verify affected model/firmware from vendor bulletin

**Do NOT:**
- Do not power-cycle mid-run or interrupt active diagnostics/production
- Do not pull device from service without approved fallback

**Actions — Do This Today:**
1. Isolate: restrict device network access to required subnets/services only
2. Credentials: rotate local creds/MFA where applicable
3. Monitoring: enable verbose logs; start manual log for abnormal temps/restarts
4. Compensating controls: apply vendor-recommended mitigations
5. Stakeholders: notify clinical/production leads

**Escalation Triggers:**
- Any abnormal temperature/reading drift or device instability
- Evidence of active exploitation on network
- No viable mitigations in regulated use

---

## Data Sources & Validation

### Primary Allowlist (Trusted by Default)
- CVE/NVD (NIST) — canonical CVE feed
- CISA/CERT advisories — sector alerts, ICS/medical bulletins
- Vendor & OEM security portals (Siemens, GE, Abbott, etc.)
- National/International CERTs (US-CERT, CERT-EU, ACSC)
- FDA/EMA notices (device/software where applicable)
- Academic/peer-reviewed sources for bio/assay impacts

### Secondary Sources (Review + Verify)
- Sector newsletters and ISAC partner notes
- Well-known threat intel blogs and DFIR posts
- Ransomware/victim leak trackers
- Community reports (GitHub issues, forums) — treat as unverified

### Denylist / High-Risk (Avoid or Quarantine)
- Anonymous pastes with no provenance
- Sites known for spoofed advisories or scam patches
- Screenshots without original link or cryptographic signature

### Validation Steps (Every Alert)
1. Record provenance: origin URL, timestamp, TLP, hash, author org
2. Cross-check at least two sources for critical claims
3. Dedupe by CVE/URL hashes
4. Tag confidence: High (vendor/CISA), Medium (reputable blog + vendor link), Low (community only)
5. Escalate unverified claims to Tier-2

---

## AI Usage Statement

### Purpose of AI in MVP
- Summarize long advisories into plain-English context
- Propose preliminary priority using Human Impact Index factors
- Draft safe-action checklists (humans confirm/trim)

### Human-in-the-Loop Controls
- Every AI output is reviewed; operators choose GO / HOLD / ESCALATE
- AI cannot recommend 'unsafe actions' (e.g., one-click shutdown)
- Content is filtered; overrides and edits are logged

### Data Handling & Safety
- AI operates on public advisories or operator-provided text
- No PHI/PII is ingested
- Known prompt-injection patterns are sanitized
- Sources are verified before summarization
- TLP tags restrict sensitive text from public artifacts

### Transparency
- AI usage disclosed in documentation
- Source attributions and confidence levels included with each alert
- Examples of AI errors and human corrections maintained for learning

---

## Assumptions & Limits

### Assumptions (MVP)
- Signals come from public sources or manually provided links (no closed APIs)
- Operators can self-identify affected assets (checkbox "Is this us?")
- Human Impact Index weights are initial heuristics (tuned with Bio-ISAC feedback)
- Tier-2 response available for high-risk cases (Whitney/partner analysts)

### Constraints / Known Gaps
- No automated asset inventory correlation in MVP (mapping is manual)
- Limited identity verification (prototype uses referral/org email checks)
- AI summaries may omit edge details (humans review before action)
- No direct EHR/LIS/SCADA integration in MVP (actions are guidance/runbook only)

### Pilot Close-Out Plan
- Add asset inventory import (CSV/API) to improve "Is this us?" accuracy
- Implement lightweight verification (email domain + invite code + optional backchannel)
- Introduce feed automation and dedupe store
- Export audit logs to SIEM
- Run A/B on Quiet Mode policy
- Re-weight Human Impact Index from real incidents

### Non-Goals (Phase 1)
- No automatic device shutdown controls
- No collection of PHI/PII beyond minimal contact and org identity
- No broad ingestion of closed, confidential datasets without explicit agreements

---

## Next Phase Plan (SOW)

### Objective
Pilot a Tier-1 triage assistant with one willing operator site and Bio-ISAC Tier-2 support.

### Scope & Deliverables

#### 1. Ingest & Dedupe (MVP Automation)
- Pull from CVE/NVD, CISA/CERT, selected vendor portals
- Normalize, hash-dedupe, tag TLP and confidence
- **Deliverable:** Running intake + dedupe store; allowlist/denylist table

#### 2. Human Impact Index v1.1 (Tuned)
- Calibrate weights with Bio-ISAC
- Add examples and red/yellow/green bands
- **Deliverable:** Rubric doc + worksheet; sample scored alerts

#### 3. Prototype App (Clickable + Thin API)
- Mission Control screen
- "Is this us?" checkbox
- GO/HOLD/ESCALATE logging
- **Deliverable:** Clickable prototype link + demo video (≤90s); minimal backend log

#### 4. Safe Action Playbooks (Starter Set)
- Two scenarios: No-patch critical (RED), Patch within 72h (YELLOW)
- **Deliverable:** PDF playbooks + blank template

#### 5. Risk/Trust & AI Safety
- Provenance receipts, verification concept, AI guardrails, logging
- **Deliverable:** Risk/Trust Model PDF; AI Usage Statement PDF

### Timeline (Suggested)
- **Week 1:** Finalize rubric, sources, and UX; build allowlist/denylist
- **Week 2:** Hook basic ingest/dedupe; produce scored sample alerts
- **Week 3:** Finalize Mission Control prototype; playbooks; demo video
- **Week 4:** Pilot walkthrough with Bio-ISAC; capture feedback; v1 SOW for Spring

### Success Criteria
- Reviewers can answer in one glance: "Does this affect us?" and "What's the safe next step?"
- At least one real-world alert scored and packaged for Tier-2 using the prototype
- Evidence of reduced alert fatigue (deduped + suppressed non-applicable items)

---

## Key Design Principles

1. **Human-Centric:** Prioritize human safety impact over technical CVSS scores
2. **Safety-First:** No unsafe actions (one-click shutdowns); favor isolation and monitoring
3. **Trust & Provenance:** Every alert includes source, confidence, and verification
4. **Fatigue Reduction:** Single-card focus, deduplication, relevance filtering
5. **Auditability:** Every decision logged with context and provenance
6. **Regulated Environment Safe:** Actions suitable for clinical/GMP/food safety contexts
7. **Human-in-the-Loop:** AI assists but humans make final decisions

---

## Technical Specifications Summary

### Scoring System
- **6 Core Factors:** Weighted 0-5 scale
- **3 Context Modifiers:** Adjust final score
- **3 Thresholds:** RED (≥70), YELLOW (40-69), GREEN (<40)
- **Max Pre-Modifier Score:** ~60 points

### Data Sources
- **Primary:** CVE/NVD, CISA/CERT, Vendor/OEM portals
- **Secondary:** Sector newsletters, threat intel blogs
- **Denylist:** Anonymous pastes, known spoofers

### User Interface
- **Full Mission Control:** Complete triage interface
- **Simple Card:** Mobile/quick demo version
- **Decision Actions:** GO / HOLD / ESCALATE

### Security & Trust
- **Provenance Tracking:** URL, timestamp, TLP, hash, confidence
- **Verification:** Org email + role attestation
- **AI Guardrails:** Filter unsafe actions, log overrides
- **Audit Trail:** Timestamped decisions with full context

---

*Analysis completed based on extracted PDF content from all design documents.*

