/**
 * Central API router for HerSignal (prefix: /api/v1).
 * Aggregates all modular route handlers.
 */
const express = require('express');
const healthRoutes = require('./health.routes');
const authRoutes = require('./auth.routes');
const passportRoutes = require('./passport.routes');
const symptomRoutes = require('./symptom.routes');
const safetyRoutes = require('./safety.routes');

const router = express.Router();

// Mount Health Check endpoint (/api/v1/health)
router.use('/health', healthRoutes);

// Mount Authentication endpoints (/api/v1/auth)
router.use('/auth', authRoutes);

// Mount Health Passport endpoints (/api/v1/passport)
router.use('/passport', passportRoutes);

// Mount Symptom Check-in endpoints (/api/v1/symptoms)
router.use('/symptoms', symptomRoutes);

// Mount Safety Triage endpoints (/api/v1/safety)
router.use('/safety', safetyRoutes);

module.exports = router;
