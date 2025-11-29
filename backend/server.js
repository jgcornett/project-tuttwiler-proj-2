// Project Tuttwiler - Backend API Server
// Express.js API for Mission Control Dashboard

import express from 'express';
import cors from 'cors';
import { db, dbAll, dbGet, dbRun } from './database.js';

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors()); // Enable CORS for frontend
app.use(express.json()); // Parse JSON request bodies

// ============================================================================
// GET /api/alerts - List all alerts with filtering and prioritization
// ============================================================================
app.get('/api/alerts', async (req, res) => {
  try {
    const { status, impact_level, limit } = req.query;
    
    // Build WHERE clause
    let whereClause = 'WHERE 1=1';
    const params = [];
    
    if (status) {
      whereClause += ' AND status = ?';
      params.push(status);
    }
    
    if (impact_level) {
      whereClause += ' AND impact_level = ?';
      params.push(impact_level);
    }
    
    // Prioritization: RED > YELLOW > GREEN, then by total_score DESC, then by detected_at DESC
    const sql = `
      SELECT * FROM alerts
      ${whereClause}
      ORDER BY 
        CASE impact_level
          WHEN 'RED' THEN 1
          WHEN 'YELLOW' THEN 2
          WHEN 'GREEN' THEN 3
        END,
        total_score DESC,
        detected_at DESC
      ${limit ? `LIMIT ${parseInt(limit)}` : ''}
    `;
    
    const alerts = await dbAll(sql, params);
    
    res.json({
      success: true,
      count: alerts.length,
      alerts: alerts
    });
  } catch (error) {
    console.error('Error fetching alerts:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch alerts',
      message: error.message
    });
  }
});

// ============================================================================
// GET /api/alerts/history - Get alerts with decisions (history view)
// MUST come before /api/alerts/:id to avoid route conflict
// ============================================================================
app.get('/api/alerts/history', async (req, res) => {
  try {
    const { limit = 50 } = req.query;
    
    // Get alerts with their most recent decision (using subquery instead of window function for compatibility)
    const sql = `
      SELECT 
        a.*,
        d.decision_type,
        d.decision_timestamp,
        d.notes as decision_notes,
        d.relevance_at_decision
      FROM alerts a
      LEFT JOIN (
        SELECT d1.*
        FROM decisions d1
        INNER JOIN (
          SELECT alert_id, MAX(decision_timestamp) as max_timestamp
          FROM decisions
          WHERE user_id = ?
          GROUP BY alert_id
        ) d2 ON d1.alert_id = d2.alert_id AND d1.decision_timestamp = d2.max_timestamp
        WHERE d1.user_id = ?
      ) d ON a.id = d.alert_id
      ORDER BY a.detected_at DESC
      LIMIT ?
    `;
    
    const alerts = await dbAll(sql, ['default_user', 'default_user', parseInt(limit)]);
    
    // Format the response
    const formattedAlerts = alerts.map(alert => ({
      id: alert.id,
      title: alert.title,
      description: alert.description,
      aiSummary: alert.ai_summary,
      timestamp: new Date(alert.detected_at).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
      }),
      date: new Date(alert.detected_at).toLocaleDateString('en-US'),
      detectedAt: alert.detected_at,
      affectedFunction: alert.affected_function,
      systemName: alert.system_name,
      impactLevel: alert.impact_level,
      impactDescription: alert.impact_description,
      status: alert.status,
      totalScore: alert.total_score,
      decisionType: alert.decision_type || null,
      decisionTimestamp: alert.decision_timestamp || null,
      decisionNotes: alert.decision_notes || null,
      relevance: alert.relevance_at_decision || alert.relevance || null
    }));
    
    res.json({
      success: true,
      count: formattedAlerts.length,
      alerts: formattedAlerts
    });
  } catch (error) {
    console.error('Error fetching alert history:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch alert history',
      message: error.message
    });
  }
});

// ============================================================================
// GET /api/alerts/:id - Get single alert with full details
// ============================================================================
app.get('/api/alerts/:id', async (req, res) => {
  try {
    const alertId = parseInt(req.params.id);
    
    // Get alert
    const alert = await dbGet('SELECT * FROM alerts WHERE id = ?', [alertId]);
    
    if (!alert) {
      return res.status(404).json({
        success: false,
        error: 'Alert not found'
      });
    }
    
    // Get provenance (sources)
    const provenance = await dbAll(
      'SELECT * FROM provenance WHERE alert_id = ? ORDER BY timestamp DESC',
      [alertId]
    );
    
    // Get safe actions
    const safeActions = await dbAll(
      'SELECT * FROM safe_actions WHERE alert_id = ? ORDER BY display_order ASC',
      [alertId]
    );
    
    // Format sources for frontend
    const sources = provenance.map(p => ({
      name: p.source_name,
      type: p.source_type,
      url: p.source_url,
      verified: p.verified === 1,
      confidence: p.confidence
    }));
    
    // Get overall confidence (highest confidence from verified sources)
    const verifiedSources = provenance.filter(p => p.verified === 1);
    let confidence = 'Low';
    if (verifiedSources.some(s => s.confidence === 'High')) {
      confidence = 'High';
    } else if (verifiedSources.some(s => s.confidence === 'Medium')) {
      confidence = 'Medium';
    }
    
    // Format safe actions
    const actionSteps = safeActions
      .filter(a => a.action_type === 'action_today' || a.action_type === 'do_not')
      .map(a => a.action_text);
    
    // Format response to match frontend structure
    const formattedAlert = {
      id: alert.id,
      title: alert.title,
      description: alert.description,
      aiSummary: alert.ai_summary,
      timestamp: new Date(alert.detected_at).toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit',
        hour12: false 
      }),
      date: new Date(alert.detected_at).toLocaleDateString('en-US'),
      affectedFunction: alert.affected_function,
      systemName: alert.system_name,
      impactLevel: alert.impact_level,
      impactDescription: alert.impact_description,
      sources: sources,
      confidence: confidence,
      safeActions: actionSteps,
      status: alert.status,
      relevance: alert.relevance,
      cveId: alert.cve_id,
      cveUrl: alert.cve_url,
      totalScore: alert.total_score,
      detectedAt: alert.detected_at
    };
    
    res.json({
      success: true,
      alert: formattedAlert
    });
  } catch (error) {
    console.error('Error fetching alert:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch alert',
      message: error.message
    });
  }
});

// ============================================================================
// GET /api/alerts/priority/top - Get top priority alert (single-card focus)
// ============================================================================
app.get('/api/alerts/priority/top', async (req, res) => {
  try {
    const sql = `
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
      LIMIT 1
    `;
    
    const alert = await dbGet(sql);
    
    if (!alert) {
      return res.json({
        success: true,
        alert: null,
        message: 'No active alerts'
      });
    }
    
    // Get full details (same as /api/alerts/:id)
    const provenance = await dbAll(
      'SELECT * FROM provenance WHERE alert_id = ? ORDER BY timestamp DESC',
      [alert.id]
    );
    
    const safeActions = await dbAll(
      'SELECT * FROM safe_actions WHERE alert_id = ? ORDER BY display_order ASC',
      [alert.id]
    );
    
    const sources = provenance.map(p => ({
      name: p.source_name,
      type: p.source_type,
      url: p.source_url,
      verified: p.verified === 1,
      confidence: p.confidence
    }));
    
    const verifiedSources = provenance.filter(p => p.verified === 1);
    let confidence = 'Low';
    if (verifiedSources.some(s => s.confidence === 'High')) {
      confidence = 'High';
    } else if (verifiedSources.some(s => s.confidence === 'Medium')) {
      confidence = 'Medium';
    }
    
    const actionSteps = safeActions
      .filter(a => a.action_type === 'action_today' || a.action_type === 'do_not')
      .map(a => a.action_text);
    
    const formattedAlert = {
      id: alert.id,
      title: alert.title,
      description: alert.description,
      aiSummary: alert.ai_summary,
      timestamp: new Date(alert.detected_at).toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit',
        hour12: false 
      }),
      date: new Date(alert.detected_at).toLocaleDateString('en-US'),
      affectedFunction: alert.affected_function,
      systemName: alert.system_name,
      impactLevel: alert.impact_level,
      impactDescription: alert.impact_description,
      sources: sources,
      confidence: confidence,
      safeActions: actionSteps,
      status: alert.status,
      relevance: alert.relevance,
      cveId: alert.cve_id,
      cveUrl: alert.cve_url,
      totalScore: alert.total_score,
      detectedAt: alert.detected_at
    };
    
    res.json({
      success: true,
      alert: formattedAlert
    });
  } catch (error) {
    console.error('Error fetching top priority alert:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch top priority alert',
      message: error.message
    });
  }
});

// ============================================================================
// POST /api/decisions - Record GO/HOLD/ESCALATE decision
// ============================================================================
app.post('/api/decisions', async (req, res) => {
  try {
    const { alertId, decisionType, userId = 'default_user', notes, relevance } = req.body;
    
    if (!alertId || !decisionType) {
      return res.status(400).json({
        success: false,
        error: 'alertId and decisionType are required'
      });
    }
    
    if (!['GO', 'HOLD', 'ESCALATE'].includes(decisionType)) {
      return res.status(400).json({
        success: false,
        error: 'decisionType must be GO, HOLD, or ESCALATE'
      });
    }
    
    // Get alert for score breakdown
    const alert = await dbGet('SELECT * FROM alerts WHERE id = ?', [alertId]);
    
    if (!alert) {
      return res.status(404).json({
        success: false,
        error: 'Alert not found'
      });
    }
    
    const scoreBreakdown = JSON.stringify({
      totalScore: alert.total_score,
      humanSafety: alert.human_safety_score,
      accuracy: alert.accuracy_score,
      dependency: alert.dependency_score,
      exploitability: alert.exploitability_score,
      patchStatus: alert.patch_status_score,
      operationalExposure: alert.operational_exposure_score
    });
    
    // Insert decision
    const result = await dbRun(
      `INSERT INTO decisions (alert_id, user_id, decision_type, relevance_at_decision, notes, score_breakdown)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [alertId, userId, decisionType, relevance || null, notes || null, scoreBreakdown]
    );
    
    // Update alert status if needed
    let newStatus = alert.status;
    if (decisionType === 'ESCALATE') {
      newStatus = 'escalated';
    } else if (decisionType === 'GO' && alert.status === 'active') {
      // Keep as active - user will take action
      newStatus = 'active';
    }
    
    if (newStatus !== alert.status) {
      await dbRun('UPDATE alerts SET status = ? WHERE id = ?', [newStatus, alertId]);
    }
    
    // Update relevance if provided
    if (relevance) {
      await dbRun('UPDATE alerts SET relevance = ? WHERE id = ?', [relevance, alertId]);
    }
    
    // Log to audit_logs
    await dbRun(
      `INSERT INTO audit_logs (alert_id, user_id, action, metadata)
       VALUES (?, ?, 'decision_made', ?)`,
      [alertId, userId, JSON.stringify({ decision: decisionType, notes: notes || null })]
    );
    
    res.json({
      success: true,
      message: 'Decision recorded successfully',
      decision: {
        id: result.lastID,
        alertId: alertId,
        decisionType: decisionType,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Error recording decision:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to record decision',
      message: error.message
    });
  }
});

// ============================================================================
// GET /api/notifications - Get user notifications
// ============================================================================
app.get('/api/notifications', async (req, res) => {
  try {
    const { userId = 'default_user', readStatus } = req.query;
    
    let sql = `
      SELECT n.*, a.title, a.impact_level, a.detected_at
      FROM notifications n
      JOIN alerts a ON n.alert_id = a.id
      WHERE n.user_id = ?
    `;
    const params = [userId];
    
    if (readStatus !== undefined) {
      sql += ' AND n.read_status = ?';
      params.push(readStatus === 'true' ? 1 : 0);
    }
    
    sql += ' ORDER BY n.created_at DESC';
    
    const notifications = await dbAll(sql, params);
    
    res.json({
      success: true,
      count: notifications.length,
      notifications: notifications
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch notifications',
      message: error.message
    });
  }
});

// ============================================================================
// Health check endpoint
// ============================================================================
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'API is running',
    timestamp: new Date().toISOString()
  });
});

// ============================================================================
// Start server
// ============================================================================
app.listen(PORT, () => {
  console.log(`🚀 Project Tuttwiler API Server running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🔔 Alerts endpoint: http://localhost:${PORT}/api/alerts`);
});

