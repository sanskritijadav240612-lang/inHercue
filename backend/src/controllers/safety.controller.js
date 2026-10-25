/**
 * Safety & Urgent Care Controller for HerSignal API.
 * Provides deterministic red-flag evaluations and crisis helpline access.
 */
const { evaluateSafetyTriage } = require('../services/safety.service');

/**
 * Evaluate acute symptoms for red-flag warning signs.
 * POST /api/v1/safety/triage
 */
function triage(req, res, next) {
  try {
    const result = evaluateSafetyTriage(req.body);

    return res.status(200).json({
      success: true,
      message: 'Safety assessment completed',
      data: result
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  triage
};
