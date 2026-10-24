/**
 * Authentication Routes for HerSignal API.
 * Mounts registration, login, and user profile verification endpoints.
 */
const express = require('express');
const { register, login, getMe } = require('../controllers/auth.controller');
const { validateRegister, validateLogin } = require('../middleware/validateAuth');
const { authenticate } = require('../middleware/auth.middleware');
const { loginLimiter, registerLimiter } = require('../middleware/rateLimiter');

const router = express.Router();

// Public routes (Rate-limited per client IP)
router.post('/register', registerLimiter, validateRegister, register);
router.post('/login', loginLimiter, validateLogin, login);

// Protected routes (Requires Bearer JWT token)
router.get('/me', authenticate, getMe);

module.exports = router;
