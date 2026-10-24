/**
 * Health check controller for HerSignal API.
 * Provides service readiness and health verification without exposing sensitive internal details.
 */
const config = require('../config/env');
const { getDbStatus } = require('../config/db');

function getHealth(req, res) {
  const dbStatus = getDbStatus();

  return res.status(200).json({
    success: true,
    message: 'HerSignal API is operational',
    data: {
      service: 'HerSignal API',
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      environment: config.nodeEnv,
      database: dbStatus
    }
  });
}

module.exports = {
  getHealth
};
