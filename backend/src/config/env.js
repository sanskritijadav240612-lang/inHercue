/**
 * Environment configuration loader for HerSignal.
 * Safely parses and exports configuration with resilient fallback defaults.
 */
const path = require('path');
const dotenv = require('dotenv');

// Load .env file from backend root if it exists
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const config = {
  port: parseInt(process.env.PORT, 10) || 5000,
  nodeEnv: process.env.NODE_ENV || 'development',
  mongoUri: process.env.MONGODB_URI || '',
  testMongoUri: process.env.TEST_MONGODB_URI || 'mongodb://127.0.0.1:27017/hersignal_test',
  jwtSecret: process.env.JWT_SECRET || 'dev_jwt_secret_placeholder',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  corsOrigin: process.env.CORS_ORIGIN || '*'
};

const knownPlaceholders = [
  'dev_jwt_secret_placeholder',
  'your_development_jwt_secret_placeholder_do_not_use_in_prod'
];

/**
 * Validates environment configuration.
 * Fails safely in production if JWT_SECRET is missing, empty, or a development placeholder.
 *
 * @param {Object} cfg - Configuration object to validate
 */
function validateEnv(cfg = config) {
  if (cfg.nodeEnv === 'production') {
    const secret = cfg.jwtSecret;
    if (!secret || typeof secret !== 'string' || secret.trim() === '' || knownPlaceholders.includes(secret.trim())) {
      throw new Error(
        '[Security Error] In production (NODE_ENV=production), JWT_SECRET must be explicitly defined with a secure value and cannot use development placeholders.'
      );
    }

    const cors = cfg.corsOrigin;
    if (
      !cors ||
      typeof cors !== 'string' ||
      cors.trim() === '' ||
      cors.trim() === '*' ||
      cors.split(',').map(s => s.trim()).includes('*')
    ) {
      throw new Error(
        '[Security Error] In production (NODE_ENV=production), CORS_ORIGIN must be explicitly set to a trusted domain allowlist and cannot be empty or wildcard (*).'
      );
    }
  }
}

// Run validation for active environment
validateEnv(config);

module.exports = {
  ...config,
  validateEnv
};
