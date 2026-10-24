/**
 * JWT Token Service for HerSignal.
 * Signs and verifies access tokens using environment-configured secrets.
 */
const jwt = require('jsonwebtoken');
const config = require('../config/env');

/**
 * Signs a new JWT for an authenticated user.
 *
 * @param {Object} user - User document or safe object
 * @returns {string} Signed JWT token
 */
function generateToken(user) {
  const payload = {
    userId: user._id ? user._id.toString() : user.userId.toString(),
    email: user.email
  };

  return jwt.sign(payload, config.jwtSecret, {
    expiresIn: config.jwtExpiresIn
  });
}

/**
 * Verifies a JWT token string.
 *
 * @param {string} token - Raw JWT string
 * @returns {Object} Decoded token payload
 * @throws {JsonWebTokenError | TokenExpiredError} If invalid or expired
 */
function verifyToken(token) {
  return jwt.verify(token, config.jwtSecret);
}

module.exports = {
  generateToken,
  verifyToken
};
