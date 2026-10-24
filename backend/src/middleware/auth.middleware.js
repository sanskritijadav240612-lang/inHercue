/**
 * JWT Authentication Middleware for HerSignal.
 * Protects authenticated endpoints and attaches the verified user to req.user.
 */
const { verifyToken } = require('../services/token.service');
const User = require('../models/user.model');

async function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      error: {
        code: 'UNAUTHORIZED',
        message: 'Authentication token is required. Please provide a Bearer token in the Authorization header.',
        details: []
      }
    });
  }

  const token = authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      error: {
        code: 'UNAUTHORIZED',
        message: 'Malformed authorization token format.',
        details: []
      }
    });
  }

  try {
    const decoded = verifyToken(token);

    if (!decoded || !decoded.userId) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Invalid token payload.',
          details: []
        }
      });
    }

    const user = await User.findById(decoded.userId);

    if (!user) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'The user account associated with this token no longer exists.',
          details: []
        }
      });
    }

    // Attach user to request
    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: {
        code: 'UNAUTHORIZED',
        message: error.name === 'TokenExpiredError'
          ? 'Authentication token has expired. Please log in again.'
          : 'Invalid authentication token.',
        details: []
      }
    });
  }
}

module.exports = {
  authenticate
};
