/**
 * Authentication Routes for HerSignal API.
 * Mounts registration, login, and user profile verification endpoints.
 */
const express = require('express');
const { register, login, getMe } = require('../controllers/auth.controller');
const { validateRegister, validateLogin } = require('../middleware/validateAuth');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

// Public routes
router.post('/register', validateRegister, register);
router.post('/login', validateLogin, login);

// Protected routes (Requires Bearer JWT token)
router.get('/me', authenticate, getMe);

module.exports = router;
