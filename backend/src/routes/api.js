/**
 * Central API router for HerSignal (prefix: /api/v1).
 * Aggregates all modular route handlers.
 */
const express = require('express');
const healthRoutes = require('./health.routes');

const router = express.Router();

// Mount Health Check endpoint (/api/v1/health)
router.use('/health', healthRoutes);

module.exports = router;
