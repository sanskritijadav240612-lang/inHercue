/**
 * HerSignal Backend Server Entry Point.
 * Starts HTTP listener and initializes database connection.
 */
const app = require('./src/app');
const config = require('./src/config/env');
const { connectDB, disconnectDB } = require('./src/config/db');

async function startServer() {
  // Enforce environment validation before starting
  if (typeof config.validateEnv === 'function') {
    config.validateEnv(config);
  }

  // Connect to MongoDB if URI is configured (optional for foundation stage)
  await connectDB({ isOptional: true });

  const server = app.listen(config.port, () => {
    console.log(`=======================================================`);
    console.log(` HerSignal API Server Running`);
    console.log(` Environment : ${config.nodeEnv}`);
    console.log(` Port        : ${config.port}`);
    console.log(` Health URL  : http://localhost:${config.port}/api/v1/health`);
    console.log(`=======================================================`);
  });

  // Graceful shutdown handling
  const shutdown = async (signal) => {
    console.log(`\n[Server] Received ${signal}. Shutting down gracefully...`);
    server.close(async () => {
      await disconnectDB();
      console.log('[Server] HTTP server closed cleanly.');
      process.exit(0);
    });
  };

  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

startServer();
