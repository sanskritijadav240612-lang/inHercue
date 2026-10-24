/**
 * Global error handling middleware for HerSignal API.
 * Adheres strictly to the standard error envelope defined in docs/api-contract.md.
 */

// 404 Not Found handler for undefined routes
function notFoundHandler(req, res, next) {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `The requested endpoint '${req.method} ${req.originalUrl}' does not exist on this server.`,
      details: []
    }
  });
}

// Global 500 / unexpected error handler
function errorHandler(err, req, res, next) {
  const statusCode = err.status || err.statusCode || 500;
  const isDev = process.env.NODE_ENV === 'development';

  console.error(`[Error] ${req.method} ${req.originalUrl}:`, err.message);

  res.status(statusCode).json({
    success: false,
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: err.message || 'An unexpected internal server error occurred.',
      details: isDev && err.details ? err.details : []
    }
  });
}

module.exports = {
  notFoundHandler,
  errorHandler
};
