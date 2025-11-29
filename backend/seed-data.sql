-- Project Tuttwiler - Seed Data
-- Populate database with realistic test alerts for development/demo
-- Run this in SQLiteStudio after schema.sql

-- Enable foreign keys
PRAGMA foreign_keys = ON;

-- Clear existing data (if any)
DELETE FROM audit_logs;
DELETE FROM decisions;
DELETE FROM notifications;
DELETE FROM safe_actions;
DELETE FROM provenance;
DELETE FROM alerts;

-- ============================================================================
-- ALERT 1: RED - Critical Lab Controller Vulnerability (No Patch)
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id, cve_url
) VALUES (
    'Critical: Controller X firmware vuln (no patch)',
    'Vulnerability in Controller X firmware version 2.4.1 may allow remote attackers to modify calibration settings without authentication. This could lead to incorrect diagnostic readings.',
    'Vulnerability in Controller X may allow remote changes to calibration. No vendor patch yet; mitigation required to protect diagnostic accuracy.',
    datetime('now', '-2 days', '-3 hours'),
    datetime('now', '-2 days', '-3 hours'),
    datetime('now', '-2 days', '-3 hours'),
    'Lab diagnostics',
    'Controller X',
    'RED',
    'Direct Care Threat',
    5, 4, 4, 3, 4, 3, 73.5,
    'active',
    'CVE-2024-1234',
    'https://nvd.nist.gov/vuln/detail/CVE-2024-1234'
);

-- Provenance for Alert 1
INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (1, 'Vendor bulletin (Siemens Medical)', 'vendor', 'https://siemens.com/security/bulletins/2024-001', 1, 'High', 'AMBER', 'https://siemens.com/security/bulletins/2024-001'),
    (1, 'CISA advisory', 'cisa', 'https://www.cisa.gov/news-events/cybersecurity-advisories/aa24-001', 1, 'High', 'AMBER', 'https://www.cisa.gov/news-events/cybersecurity-advisories/aa24-001'),
    (1, 'CVE/NVD entry', 'cve', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1234', 1, 'High', 'GREEN', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1234');

-- Safe Actions for Alert 1
INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (1, 1, 'Do not power-cycle during active runs.', 'do_not', 1),
    (1, 2, 'Restrict Controller X network access to required systems only.', 'action_today', 2),
    (1, 3, 'Log abnormal temps/restarts; escalate if observed.', 'action_today', 3),
    (1, 4, 'Enable verbose logging on Controller X.', 'monitoring', 4),
    (1, 5, 'Notify clinical/production leads immediately.', 'action_today', 5);

-- Notification for Alert 1
INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (1, 'default_user', 0, datetime('now', '-2 days', '-3 hours'));

-- ============================================================================
-- ALERT 2: RED - Food Processing System Compromise
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id
) VALUES (
    'Critical: Active exploitation detected in food processing SCADA',
    'Threat actors are actively targeting food processing SCADA systems with ransomware. Multiple facilities have been compromised in the past 48 hours.',
    'Active ransomware campaign targeting food processing SCADA systems. No patch available; immediate isolation and monitoring required.',
    datetime('now', '-1 day', '-5 hours'),
    datetime('now', '-1 day', '-5 hours'),
    datetime('now', '-1 day', '-5 hours'),
    'Food safety',
    'Processing SCADA System',
    'RED',
    'Food Safety Threat',
    5, 5, 5, 5, 5, 5, 85.0,
    'active',
    'CVE-2024-2156'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (2, 'CISA/CERT advisory', 'cisa', 'https://www.cisa.gov/news-events/cybersecurity-advisories/aa24-015', 1, 'High', 'AMBER', 'https://www.cisa.gov/news-events/cybersecurity-advisories/aa24-015'),
    (2, 'Industry ISAC alert', 'isac', 'https://foodisac.org/alerts/2024-015', 1, 'High', 'AMBER', 'https://foodisac.org/alerts/2024-015');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (2, 1, 'Isolate SCADA network from corporate network immediately.', 'action_today', 1),
    (2, 2, 'Do not disconnect from production systems during active runs.', 'do_not', 2),
    (2, 3, 'Enable network monitoring on all SCADA endpoints.', 'monitoring', 3),
    (2, 4, 'Rotate all SCADA system credentials immediately.', 'action_today', 4),
    (2, 5, 'Review recent access logs for suspicious activity.', 'action_today', 5);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (2, 'default_user', 0, datetime('now', '-1 day', '-5 hours'));

-- ============================================================================
-- ALERT 3: YELLOW - Vendor Patch Available (72h window)
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id
) VALUES (
    'Moderate: Diagnostic software update available',
    'Vendor has released patch for diagnostic software version 3.2. Patch addresses authentication bypass vulnerability. Patch available within 72-hour maintenance window.',
    'Authentication bypass vulnerability patched. Vendor patch available; schedule maintenance window within 72 hours.',
    datetime('now', '-1 day', '-2 hours'),
    datetime('now', '-1 day', '-2 hours'),
    datetime('now', '-1 day', '-2 hours'),
    'Lab diagnostics',
    'Diagnostic Software v3.2',
    'YELLOW',
    'Service Continuity',
    2, 2, 3, 2, 2, 2, 42.5,
    'active',
    'CVE-2024-1892'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (3, 'Vendor bulletin (Abbott Laboratories)', 'vendor', 'https://www.abbott.com/security/advisories/2024-002', 1, 'High', 'GREEN', 'https://www.abbott.com/security/advisories/2024-002'),
    (3, 'CVE/NVD entry', 'cve', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1892', 1, 'High', 'GREEN', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1892');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (3, 1, 'Review vendor patch notes and test in non-production environment.', 'pre_check', 1),
    (3, 2, 'Schedule patch window within 72 hours during low-activity period.', 'action_today', 2),
    (3, 3, 'Notify stakeholders of planned maintenance window.', 'action_today', 3),
    (3, 4, 'Backup current configuration before patching.', 'pre_check', 4);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (3, 'default_user', 0, datetime('now', '-1 day', '-2 hours'));

-- ============================================================================
-- ALERT 4: YELLOW - Medical Device Firmware Update
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id
) VALUES (
    'Moderate: Patient monitoring system firmware update required',
    'Firmware update available for patient monitoring devices addresses data integrity issue. Update recommended within next maintenance cycle.',
    'Patient monitoring firmware update addresses data integrity. Schedule update during next planned maintenance.',
    datetime('now', '-12 hours'),
    datetime('now', '-12 hours'),
    datetime('now', '-12 hours'),
    'Clinical monitoring',
    'Patient Monitor Series 5000',
    'YELLOW',
    'Service Continuity',
    3, 3, 4, 2, 1, 2, 50.0,
    'active',
    'CVE-2024-2015'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (4, 'Vendor bulletin (GE Healthcare)', 'vendor', 'https://www.gehealthcare.com/security/2024-003', 1, 'High', 'GREEN', 'https://www.gehealthcare.com/security/2024-003'),
    (4, 'FDA medical device alert', 'fda', 'https://www.fda.gov/medical-devices/device-alerts/2024-015', 1, 'High', 'GREEN', 'https://www.fda.gov/medical-devices/device-alerts/2024-015');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (4, 1, 'Do not update devices during active patient monitoring sessions.', 'do_not', 1),
    (4, 2, 'Test firmware update on one device before full deployment.', 'pre_check', 2),
    (4, 3, 'Schedule firmware update during scheduled maintenance window.', 'action_today', 3),
    (4, 4, 'Coordinate with clinical staff for maintenance window.', 'action_today', 4);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (4, 'default_user', 0, datetime('now', '-12 hours'));

-- ============================================================================
-- ALERT 5: GREEN - Low Priority UI Library Update
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id
) VALUES (
    'Informational: Kiosk UI library outdated',
    'UI library used in patient check-in kiosks has an available update. Vulnerability is low-risk and does not affect clinical systems.',
    'Non-critical UI library update available for kiosk systems. Track and patch in normal maintenance cycle.',
    datetime('now', '-3 days'),
    datetime('now', '-3 days'),
    datetime('now', '-3 days'),
    'Patient services',
    'Check-in Kiosk UI',
    'GREEN',
    'Informational',
    0, 0, 1, 2, 1, 1, 12.5,
    'active',
    'CVE-2024-1789'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (5, 'CVE/NVD entry', 'cve', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1789', 1, 'High', 'GREEN', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1789'),
    (5, 'Community report', 'community', 'https://github.com/ui-library/issues/123', 0, 'Low', 'GREEN', 'https://github.com/ui-library/issues/123');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (5, 1, 'Add to next quarterly patch cycle.', 'action_today', 1),
    (5, 2, 'Monitor for any related security advisories.', 'monitoring', 2);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (5, 'default_user', 1, datetime('now', '-3 days')); -- Already read

-- ============================================================================
-- ALERT 6: RED - Ransomware Campaign Targeting Healthcare
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status
) VALUES (
    'Critical: Active ransomware campaign targeting healthcare facilities',
    'Healthcare facilities are being actively targeted by ransomware group. Multiple hospitals have been affected. Immediate defensive actions required.',
    'Active ransomware campaign targeting healthcare. Immediate isolation of critical systems and enhanced monitoring required.',
    datetime('now', '-6 hours'),
    datetime('now', '-6 hours'),
    datetime('now', '-6 hours'),
    'Infrastructure',
    'Hospital Network',
    'RED',
    'Direct Care Threat',
    5, 4, 5, 5, 4, 5, 88.0,
    'active'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (6, 'CISA/CERT emergency alert', 'cisa', 'https://www.cisa.gov/news-events/alerts/aa24-020', 1, 'High', 'RED', 'https://www.cisa.gov/news-events/alerts/aa24-020'),
    (6, 'Healthcare ISAC bulletin', 'isac', 'https://h-isac.org/alerts/2024-020', 1, 'High', 'RED', 'https://h-isac.org/alerts/2024-020'),
    (6, 'FBI Flash Alert', 'government', 'https://www.ic3.gov/alerts/flash-2024-015', 1, 'High', 'RED', 'https://www.ic3.gov/alerts/flash-2024-015');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (6, 1, 'Isolate non-essential systems from network immediately.', 'action_today', 1),
    (6, 2, 'Enable enhanced logging on all network devices.', 'monitoring', 2),
    (6, 3, 'Review and restrict external network access points.', 'action_today', 3),
    (6, 4, 'Verify backup systems are operational and recent.', 'pre_check', 4),
    (6, 5, 'Escalate to Tier-2 immediately for threat assessment.', 'escalation_trigger', 5);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (6, 'default_user', 0, datetime('now', '-6 hours'));

-- ============================================================================
-- ALERT 7: YELLOW - Lab Equipment Network Isolation
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id
) VALUES (
    'Moderate: Lab analyzer network configuration vulnerability',
    'Lab analyzer devices discovered on public-facing network segment. Configuration vulnerability allows unauthorized access. Remediation guidance available.',
    'Lab analyzers on public network segment pose security risk. Network segmentation and access controls required.',
    datetime('now', '-18 hours'),
    datetime('now', '-18 hours'),
    datetime('now', '-18 hours'),
    'Lab diagnostics',
    'Lab Analyzer Network',
    'YELLOW',
    'Service Continuity',
    2, 3, 3, 3, 2, 4, 48.0,
    'active',
    'CVE-2024-1950'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (7, 'Internal security scan', 'internal', 'internal://scan-2024-015', 1, 'Medium', 'GREEN', 'internal://scan-2024-015'),
    (7, 'CVE/NVD entry', 'cve', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1950', 1, 'High', 'GREEN', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1950');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (7, 1, 'Move lab analyzers to isolated network segment.', 'action_today', 1),
    (7, 2, 'Configure firewall rules to restrict external access.', 'action_today', 2),
    (7, 3, 'Verify lab operations continue normally after network change.', 'monitoring', 3),
    (7, 4, 'Update network documentation with new configuration.', 'action_today', 4);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (7, 'default_user', 0, datetime('now', '-18 hours'));

-- ============================================================================
-- ALERT 8: GREEN - Outdated Browser on Admin Terminal
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status
) VALUES (
    'Informational: Admin terminal browser update available',
    'Administrative workstations are running outdated browser versions. Update available through standard patching process.',
    'Browser updates available for admin terminals. Low priority; include in next patch cycle.',
    datetime('now', '-4 days'),
    datetime('now', '-4 days'),
    datetime('now', '-4 days'),
    'Administration',
    'Admin Workstations',
    'GREEN',
    'Informational',
    0, 0, 1, 1, 1, 2, 8.0,
    'active'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (8, 'Internal patch management scan', 'internal', 'internal://patches/2024-012', 1, 'Medium', 'GREEN', 'internal://patches/2024-012');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (8, 1, 'Include browser updates in next scheduled patch window.', 'action_today', 1),
    (8, 2, 'Test browser updates on non-production admin terminal first.', 'pre_check', 2);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (8, 'default_user', 1, datetime('now', '-4 days'));

-- ============================================================================
-- ALERT 9: YELLOW - Food Storage Monitoring System
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id
) VALUES (
    'Moderate: Temperature monitoring system authentication weakness',
    'Temperature monitoring system used for cold-chain storage has weak authentication. Patch available. Food safety monitoring not directly affected, but system access should be secured.',
    'Temperature monitoring system authentication weakness identified. Patch available; schedule during next maintenance window.',
    datetime('now', '-8 hours'),
    datetime('now', '-8 hours'),
    datetime('now', '-8 hours'),
    'Food safety',
    'Cold-Chain Monitoring System',
    'YELLOW',
    'Service Continuity',
    3, 2, 3, 3, 1, 3, 45.0,
    'active',
    'CVE-2024-2021'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (9, 'Vendor security advisory', 'vendor', 'https://vendor.com/security/2024-005', 1, 'High', 'GREEN', 'https://vendor.com/security/2024-005'),
    (9, 'CVE/NVD entry', 'cve', 'https://nvd.nist.gov/vuln/detail/CVE-2024-2021', 1, 'High', 'GREEN', 'https://nvd.nist.gov/vuln/detail/CVE-2024-2021');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (9, 1, 'Do not interrupt temperature monitoring during active storage operations.', 'do_not', 1),
    (9, 2, 'Schedule patch during next planned maintenance window.', 'action_today', 2),
    (9, 3, 'Strengthen authentication credentials as interim measure.', 'action_today', 3),
    (9, 4, 'Verify temperature monitoring continues normally after patch.', 'monitoring', 4);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (9, 'default_user', 0, datetime('now', '-8 hours'));

-- ============================================================================
-- ALERT 10: RED - Critical Medical Device Vulnerability
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id
) VALUES (
    'Critical: Infusion pump remote access vulnerability',
    'Infusion pumps have remote access vulnerability that could allow unauthorized control. No patch available yet. Immediate mitigation required.',
    'Infusion pump vulnerability allows unauthorized remote access. No patch available; immediate network isolation and monitoring required.',
    datetime('now', '-3 hours'),
    datetime('now', '-3 hours'),
    datetime('now', '-3 hours'),
    'Clinical care',
    'Infusion Pump Series 3000',
    'RED',
    'Direct Care Threat',
    5, 5, 5, 4, 5, 4, 82.5,
    'active',
    'CVE-2024-2105'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (10, 'FDA medical device alert', 'fda', 'https://www.fda.gov/medical-devices/device-alerts/2024-018', 1, 'High', 'RED', 'https://www.fda.gov/medical-devices/device-alerts/2024-018'),
    (10, 'CISA/CERT advisory', 'cisa', 'https://www.cisa.gov/news-events/cybersecurity-advisories/aa24-018', 1, 'High', 'RED', 'https://www.cisa.gov/news-events/cybersecurity-advisories/aa24-018'),
    (10, 'Vendor emergency bulletin', 'vendor', 'https://vendor.com/security/emergency-2024-001', 1, 'High', 'RED', 'https://vendor.com/security/emergency-2024-001');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (10, 1, 'Disconnect infusion pumps from network immediately except during active use.', 'action_today', 1),
    (10, 2, 'Do not disconnect pumps during active patient infusions.', 'do_not', 2),
    (10, 3, 'Monitor all pump communications for unauthorized access attempts.', 'monitoring', 3),
    (10, 4, 'Implement physical access controls on pump configuration ports.', 'action_today', 4),
    (10, 5, 'Escalate to Tier-2 and notify clinical staff immediately.', 'escalation_trigger', 5);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (10, 'default_user', 0, datetime('now', '-3 hours'));

-- ============================================================================
-- ALERT 11: YELLOW - Database Server Update
-- ============================================================================
INSERT INTO alerts (
    title, description, ai_summary, detected_at, created_at, updated_at,
    affected_function, system_name, impact_level, impact_description,
    human_safety_score, accuracy_score, dependency_score, exploitability_score,
    patch_status_score, operational_exposure_score, total_score,
    status, cve_id
) VALUES (
    'Moderate: Database server security update available',
    'Database server running patient records has security update available. Update addresses privilege escalation vulnerability. Patch recommended within maintenance window.',
    'Database server security update available. Schedule patch during next maintenance window after backup verification.',
    datetime('now', '-10 hours'),
    datetime('now', '-10 hours'),
    datetime('now', '-10 hours'),
    'Data management',
    'Patient Records Database',
    'YELLOW',
    'Service Continuity',
    2, 2, 4, 2, 1, 3, 43.0,
    'active',
    'CVE-2024-1985'
);

INSERT INTO provenance (alert_id, source_name, source_type, source_url, verified, confidence, tlp_marking, origin_url)
VALUES 
    (11, 'Database vendor security bulletin', 'vendor', 'https://dbvendor.com/security/2024-008', 1, 'High', 'GREEN', 'https://dbvendor.com/security/2024-008'),
    (11, 'CVE/NVD entry', 'cve', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1985', 1, 'High', 'GREEN', 'https://nvd.nist.gov/vuln/detail/CVE-2024-1985');

INSERT INTO safe_actions (alert_id, step_number, action_text, action_type, display_order)
VALUES 
    (11, 1, 'Verify database backups are current and tested before patching.', 'pre_check', 1),
    (11, 2, 'Schedule patch window during low-traffic period.', 'action_today', 2),
    (11, 3, 'Test patch on staging environment first.', 'pre_check', 3),
    (11, 4, 'Notify stakeholders of planned maintenance window.', 'action_today', 4);

INSERT INTO notifications (alert_id, user_id, read_status, created_at)
VALUES (11, 'default_user', 0, datetime('now', '-10 hours'));

-- ============================================================================
-- Sample Decisions (for testing)
-- ============================================================================
INSERT INTO decisions (alert_id, user_id, decision_type, decision_timestamp, relevance_at_decision, notes)
VALUES 
    (5, 'default_user', 'HOLD', datetime('now', '-3 days', '+1 hour'), 'no', 'Not relevant - kiosks not in production use'),
    (8, 'default_user', 'GO', datetime('now', '-4 days', '+2 hours'), 'yes', 'Added to next patch cycle');

-- ============================================================================
-- Sample Audit Logs
-- ============================================================================
INSERT INTO audit_logs (alert_id, user_id, action, action_timestamp, metadata)
VALUES 
    (1, 'default_user', 'alert_viewed', datetime('now', '-2 days', '-2 hours'), '{"view_duration": 45}'),
    (1, 'default_user', 'alert_viewed', datetime('now', '-2 days', '-1 hour'), '{"view_duration": 120}'),
    (5, 'default_user', 'decision_made', datetime('now', '-3 days', '+1 hour'), '{"decision": "HOLD", "reason": "Not relevant"}'),
    (8, 'default_user', 'decision_made', datetime('now', '-4 days', '+2 hours'), '{"decision": "GO", "reason": "Added to patch cycle"}');

-- ============================================================================
-- Verify data inserted
-- ============================================================================
SELECT 'Seed data inserted successfully!' as status;
SELECT COUNT(*) as total_alerts FROM alerts;
SELECT COUNT(*) as total_provenance FROM provenance;
SELECT COUNT(*) as total_safe_actions FROM safe_actions;
SELECT COUNT(*) as total_notifications FROM notifications;

