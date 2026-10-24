/**
 * MongoDB connection manager for HerSignal.
 * Prepared for future persistence with optional connection behavior during foundation phase.
 */
const mongoose = require('mongoose');
const config = require('./env');

/**
 * Checks current connection state.
 * readyState: 0 = disconnected, 1 = connected, 2 = connecting, 3 = disconnecting
 */
function getDbStatus() {
  const state = mongoose.connection.readyState;
  const isConnected = state === 1;

  const stateNames = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting'
  };

  return {
    connected: isConnected,
    status: stateNames[state] || 'unknown'
  };
}

/**
 * Connects to MongoDB if URI is configured.
 * Operates gracefully in standalone mode if URI is absent or connection fails.
 *
 * @param {Object} options
 * @param {boolean} options.isOptional - When true, connection failures will not terminate the process.
 */
async function connectDB(options = { isOptional: true }) {
  const uri = config.mongoUri;

  if (!uri || uri.trim() === '') {
    console.log('[Database] MONGODB_URI is not set. Operating in standalone mode without active database.');
    return { connected: false, reason: 'URI_NOT_CONFIGURED' };
  }

  try {
    const conn = await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 3000
    });
    console.log(`[Database] MongoDB connected successfully to host: ${conn.connection.host}`);
    return { connected: true, host: conn.connection.host };
  } catch (error) {
    console.warn(`[Database] MongoDB connection attempt failed: ${error.message}`);
    if (!options.isOptional) {
      throw error;
    }
    console.log('[Database] Continuing in standalone mode without database connection.');
    return { connected: false, reason: 'CONNECTION_FAILED', error: error.message };
  }
}

/**
 * Disconnects from MongoDB gracefully.
 */
async function disconnectDB() {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
    console.log('[Database] MongoDB disconnected cleanly.');
  }
}

module.exports = {
  connectDB,
  disconnectDB,
  getDbStatus
};
