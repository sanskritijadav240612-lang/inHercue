/**
 * Express Application configuration for HerSignal.
 * Exported separately from server.js to facilitate automated testing.
 */
const express = require('express');
const cors = require('cors');
const config = require('./config/env');
const apiRoutes = require('./routes/api');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');

const app = express();

// Core Middleware
app.use(cors({ origin: config.corsOrigin }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Root Greeting (Convenience endpoint for browser / testing)
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to HerSignal API. Access the health check at /api/v1/health',
    documentation: 'See docs/api-contract.md for full endpoint specifications.'
  });
});

// Mount /api/v1 routes
app.use('/api/v1', apiRoutes);

// Error Handling Middleware
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
