/**
 * Authentication Rate Limiting Middleware for inHERcue API.
 * Protects login and registration endpoints against brute-force attacks and credential stuffing.
 * Adheres to the standard error envelope defined in docs/api-contract.md.
 */
const { rateLimit } = require('express-rate-limit');

/**
 * Creates a standard error response handler for rate limit exceedances.
 * Returns HTTP 429 with standard error envelope.
 *
 * @param {string} message - User-friendly message explaining the cooldown period
 * @returns {Function} Express rate limit handler
 */
function createRateLimitHandler(message) {
  return (req, res /* , next, options */) => {
    return res.status(429).json({
      success: false,
      error: {
        code: 'RATE_LIMIT_EXCEEDED',
        message: message,
        details: []
      }
    });
  };
}

/**
 * Factory for creating configured rate limiters.
 * Standardizes draft-7 RateLimit-* headers and error responses.
 *
 * @param {Object} options
 * @param {number} options.windowMs - Time window in milliseconds
 * @param {number} options.max - Maximum requests allowed per window per client IP
 * @param {string} options.message - Error message when limit is exceeded
 * @param {boolean} [options.skipSuccessfulRequests=false] - When true, only failed requests count
 * @returns {Function} Express middleware
 */
function createAuthRateLimiter({
  windowMs,
  max,
  message,
  skipSuccessfulRequests = false
}) {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: 'draft-7', // Emits modern RateLimit-Policy, RateLimit-Limit, RateLimit-Remaining, RateLimit-Reset
    legacyHeaders: false, // Disables deprecated X-RateLimit-* headers
    handler: createRateLimitHandler(message),
    skipSuccessfulRequests,
    // Do not trust unverified forwarded headers; rely on verified socket IP
    validate: {
      trustProxy: false,
      xForwardedForHeader: false
    }
  });
}

// -----------------------------------------------------------------------------
// Production Auth Limiters
// -----------------------------------------------------------------------------

const isTest = process.env.NODE_ENV === 'test' || process.execArgv.some(arg => arg.startsWith('--test'));

// Login limiter: Maximum 5 attempts per 15 minutes per client IP (relaxed during automated test runs)
const loginLimiter = createAuthRateLimiter({
  windowMs: isTest ? 1000 : 15 * 60 * 1000, // 15 minutes
  max: isTest ? 1000 : 5,
  message: 'Too many login attempts from this IP address. Please try again after 15 minutes.'
});

// Registration limiter: Maximum 3 attempts per hour per client IP (relaxed during automated test runs)
const registerLimiter = createAuthRateLimiter({
  windowMs: isTest ? 1000 : 60 * 60 * 1000, // 1 hour
  max: isTest ? 1000 : 3,
  message: 'Too many registration attempts from this IP address. Please try again after an hour.'
});

module.exports = {
  loginLimiter,
  registerLimiter,
  createAuthRateLimiter,
  createRateLimitHandler
};
