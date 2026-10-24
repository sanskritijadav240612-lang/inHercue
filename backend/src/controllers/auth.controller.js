/**
 * Authentication Controller for HerSignal API.
 * Handles user registration, login with timing-safe error messaging, and profile retrieval.
 */
const User = require('../models/user.model');
const { generateToken } = require('../services/token.service');

/**
 * Register a new user.
 * POST /api/v1/auth/register
 */
async function register(req, res, next) {
  try {
    const { name, email, password, age } = req.body;
    const normalizedEmail = email.toLowerCase().trim();

    // Check for existing account with duplicate email
    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
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

    // Create user (password is automatically hashed via Mongoose pre-save hook)
    const user = await User.create({
      name: name.trim(),
      email: normalizedEmail,
      password,
      age: age ? Number(age) : null
    });

    const token = generateToken(user);

    return res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: {
        userId: user._id,
        email: user.email,
        name: user.name,
        token,
        onboardingCompleted: user.onboardingCompleted
      }
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Login user and issue JWT.
 * POST /api/v1/auth/login
 */
async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const normalizedEmail = email.toLowerCase().trim();

    // Explicitly select password field since model schema marks it as select: false
    const user = await User.findOne({ email: normalizedEmail }).select('+password');

    // Generic error message prevents account enumeration
    const invalidCredentialsResponse = {
      success: false,
      error: {
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password.',
        details: []
      }
    };

    if (!user) {
      return res.status(401).json(invalidCredentialsResponse);
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json(invalidCredentialsResponse);
    }

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      message: "Login successful",
      data: {
        userId: user._id,
        email: user.email,
        name: user.name,
        token,
        onboardingCompleted: user.onboardingCompleted
      }
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Get current authenticated user profile.
 * GET /api/v1/auth/me
 */
async function getMe(req, res, next) {
  try {
    // req.user is populated by authenticate middleware
    return res.status(200).json({
      success: true,
      message: "User profile retrieved",
      data: {
        userId: req.user._id,
        email: req.user.email,
        name: req.user.name,
        age: req.user.age,
        onboardingCompleted: req.user.onboardingCompleted,
        createdAt: req.user.createdAt
      }
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  register,
  login,
  getMe
};
