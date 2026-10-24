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

// Global error handler
function errorHandler(err, req, res, next) {
  // Handle MongoDB duplicate key error (code 11000 race condition on unique indexes)
  if (err.code === 11000) {
    return res.status(409).json({
      success: false,
      error: {
        code: 'DUPLICATE_EMAIL',
        message: 'An account with this email address already exists.',
        details: [
          {
            field: 'email',
            issue: 'Email address is already registered.'
          }
        ]
      }
    });
  }

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
