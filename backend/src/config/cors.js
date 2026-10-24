/**
 * Safe CORS Configuration for inHERcue API.
 * Balances browser origin security with seamless native mobile & local development support.
 */
const config = require('./env');

/**
 * Parses configured CORS origins from environment string.
 * Supports comma-separated origin strings:
 * e.g., "http://localhost:3000,http://localhost:8443,https://app.inhercue.example.com"
 *
 * @param {string} [rawOrigin] - Raw env string
 * @returns {string[]} Array of normalized allowed origin strings
 */
function getParsedOrigins(rawOrigin = config.corsOrigin, isDevelopment = false) {
  if (!rawOrigin || typeof rawOrigin !== 'string') {
    return isDevelopment ? ['*'] : [];
  }
  return rawOrigin
    .split(',')
    .map(o => o.trim())
    .filter(Boolean);
}

/**
 * Validates whether an incoming browser Origin is permitted.
 *
 * Rules:
 * 1. Non-browser clients (native mobile Flutter apps, curl, server-to-server) do not
 *    send an Origin header. These are always permitted.
 * 2. Wildcard '*' is permitted ONLY in development mode. In production, an explicit
 *    allowlist match is required.
 * 3. Exact string match against configured allowlist.
 * 4. In development mode, localhost/127.0.0.1 on any port is automatically allowed to
 *    support Flutter web ephemeral ports and Vite dev servers.
 *
 * @param {string|undefined} origin - Incoming Origin header value
 * @param {string[]} allowedOrigins - Configured origin allowlist
 * @param {boolean} isDevelopment - True when NODE_ENV === 'development'
 * @returns {boolean} True if origin is allowed, false otherwise
 */
function isOriginAllowed(origin, allowedOrigins, isDevelopment = false) {
  // 1. Non-browser / native mobile requests (no Origin header)
  if (!origin) {
    return true;
  }

  // 2. Wildcard configuration (permitted ONLY in development mode)
  if (isDevelopment && allowedOrigins.includes('*')) {
    return true;
  }

  // 3. Exact allowlist match
  if (allowedOrigins.includes(origin)) {
    return true;
  }

  // 4. Development mode localhost regex (matches http://localhost:<port> or http://127.0.0.1:<port>)
  if (isDevelopment) {
    const localhostPattern = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;
    if (localhostPattern.test(origin)) {
      return true;
    }
  }

  return false;
}

/**
 * Generates CORS middleware options for Express.
 *
 * @param {Object} [overrides={}] - Optional configuration overrides (useful for testing)
 * @returns {Object} express cors options
 */
function createCorsOptions(overrides = {}) {
  const nodeEnv = overrides.nodeEnv !== undefined ? overrides.nodeEnv : config.nodeEnv;
  const isDev = nodeEnv === 'development';
  const rawOrigin = overrides.corsOrigin !== undefined ? overrides.corsOrigin : config.corsOrigin;
  const allowedOrigins = getParsedOrigins(rawOrigin, isDev);

  return {
    origin: (origin, callback) => {
      if (isOriginAllowed(origin, allowedOrigins, isDev)) {
        return callback(null, true);
      }

      const corsError = new Error(`Origin '${origin}' is not permitted by CORS policy.`);
      corsError.status = 403;
      corsError.code = 'CORS_FORBIDDEN';
      return callback(corsError);
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    credentials: false // inHERcue uses Authorization: Bearer tokens, not cross-origin cookies
  };
}

module.exports = {
  createCorsOptions,
  getParsedOrigins,
  isOriginAllowed
};
