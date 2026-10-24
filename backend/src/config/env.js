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
  jwtSecret: process.env.JWT_SECRET || 'dev_jwt_secret_placeholder',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  corsOrigin: process.env.CORS_ORIGIN || '*'
};

module.exports = config;
