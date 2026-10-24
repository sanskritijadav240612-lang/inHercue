/**
 * Request validation middleware for Authentication endpoints.
 * Validates payloads and responds with standard error envelopes upon failure.
 */

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
// Minimum 8 characters, at least one number, at least one special character
const passwordNumberRegex = /[0-9]/;
const passwordSpecialRegex = /[^a-zA-Z0-9]/;

function validateRegister(req, res, next) {
  const { name, email, password, age } = req.body || {};
  const details = [];

  // Validate Name
  if (!name || typeof name !== 'string' || name.trim().length < 2 || name.trim().length > 60) {
    details.push({
      field: 'name',
      issue: 'Name is required and must be between 2 and 60 characters long.'
    });
  }

  // Validate Email
  if (!email || typeof email !== 'string' || !emailRegex.test(email.trim())) {
    details.push({
      field: 'email',
      issue: 'A valid email address is required.'
    });
  }

  // Validate Password
  if (!password || typeof password !== 'string') {
    details.push({
      field: 'password',
      issue: 'Password is required.'
    });
  } else {
    if (password.length < 8) {
      details.push({
        field: 'password',
        issue: 'Password must be at least 8 characters long.'
      });
    }
    if (!passwordNumberRegex.test(password)) {
      details.push({
        field: 'password',
        issue: 'Password must contain at least one number.'
      });
    }
    if (!passwordSpecialRegex.test(password)) {
      details.push({
        field: 'password',
        issue: 'Password must contain at least one special character.'
      });
    }
  }

  // Validate Optional Age
  if (age !== undefined && age !== null && age !== '') {
    const parsedAge = Number(age);
    if (!Number.isInteger(parsedAge) || parsedAge < 13 || parsedAge > 120) {
      details.push({
        field: 'age',
        issue: 'Age must be an integer between 13 and 120.'
      });
    }
  }

  if (details.length > 0) {
    return res.status(422).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid registration input.',
        details
      }
    });
  }

  next();
}

function validateLogin(req, res, next) {
  const { email, password } = req.body || {};
  const details = [];

  if (!email || typeof email !== 'string' || !emailRegex.test(email.trim())) {
    details.push({
      field: 'email',
      issue: 'A valid email address is required.'
    });
  }

  if (!password || typeof password !== 'string' || password.length === 0) {
    details.push({
      field: 'password',
      issue: 'Password is required.'
    });
  }

  if (details.length > 0) {
    return res.status(422).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid login credentials format.',
        details
      }
    });
  }

  next();
}

module.exports = {
  validateRegister,
  validateLogin
};
