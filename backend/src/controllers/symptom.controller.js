/**
 * Symptom Check-in Controller for HerSignal API.
 * Manages daily health logging, history retrieval, and integrates deterministic safety triage.
 */
const SymptomLog = require('../models/symptom.model');
const { evaluateSafetyTriage } = require('../services/safety.service');

/**
 * Record a daily symptom check-in.
 * POST /api/v1/symptoms/check-in
 */
async function saveCheckin(req, res, next) {
  try {
    const {
      date,
      flow,
      painScale,
      symptoms,
      hydration,
      sleep,
      energy,
      activity,
      appetite,
      mood,
      notes
    } = req.body;

    const logDate = date && typeof date === 'string' && date.trim()
      ? date.trim()
      : new Date().toISOString().split('T')[0];

    const parsedPain = painScale !== undefined ? Number(painScale) : 0;
    const acuteList = Array.isArray(symptoms)
      ? symptoms.map(s => typeof s === 'string' ? s : s.type)
      : [];

    // Run deterministic safety triage evaluation
    const safetyResult = evaluateSafetyTriage({
      acuteSymptoms: acuteList,
      painScale: parsedPain,
      bleedingRate: flow === 'heavy' ? 'heavy_bleeding' : ''
    });

    const checkinLog = await SymptomLog.create({
      userId: req.user._id,
      date: logDate,
      flow: flow || 'none',
      painScale: parsedPain,
      symptoms: Array.isArray(symptoms) ? symptoms : [],
      hydration: hydration || null,
      sleep: sleep || null,
      energy: energy || null,
      activity: activity || null,
      appetite: appetite || null,
      mood: mood || null,
      notes: notes || '',
      safetyAssessment: {
        isEmergency: safetyResult.isRedFlag,
        triageLevel: safetyResult.triageLevel,
        advice: safetyResult.isRedFlag
          ? safetyResult.alertHeadline + ': ' + safetyResult.actionRequired
          : 'Logged successfully. Routine self-care applies.'
      }
    });

    return res.status(201).json({
      success: true,
      message: 'Symptom check-in saved',
      data: {
        logId: checkinLog._id,
        date: checkinLog.date,
        safetyAssessment: checkinLog.safetyAssessment,
        log: checkinLog
      }
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Query symptom history for authenticated user.
 * GET /api/v1/symptoms/history
 */
async function getHistory(req, res, next) {
  try {
    const { startDate, endDate, limit = 50 } = req.query;
    const filter = { userId: req.user._id };

    if (startDate || endDate) {
      filter.date = {};
      if (startDate) filter.date.$gte = startDate;
      if (endDate) filter.date.$lte = endDate;
    }

    const logs = await SymptomLog.find(filter)
      .sort({ date: -1, createdAt: -1 })
      .limit(Number(limit) || 50);

    return res.status(200).json({
      success: true,
      message: 'Symptom history retrieved',
      data: {
        logs,
        count: logs.length
      }
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Get latest check-in record for authenticated user.
 * GET /api/v1/symptoms/latest
 */
async function getLatest(req, res, next) {
  try {
    const latest = await SymptomLog.findOne({ userId: req.user._id })
      .sort({ date: -1, createdAt: -1 });

    return res.status(200).json({
      success: true,
      message: latest ? 'Latest check-in retrieved' : 'No check-ins recorded yet',
      data: latest
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  saveCheckin,
  getHistory,
  getLatest
};
