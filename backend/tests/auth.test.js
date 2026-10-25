/**
 * Automated tests for HerSignal Authentication Module.
 * Covers user registration, password hashing, login, input validation,
 * duplicate accounts, and JWT-protected route access.
 */
const { describe, it, before, after, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const mongoose = require('mongoose');

const app = require('../src/app');
const config = require('../src/config/env');
const User = require('../src/models/user.model');

describe('HerSignal API - Authentication Module Tests', () => {
  // Connect to isolated test database before running tests
  before(async () => {
    // If mongoose is connected to another DB, disconnect first
    if (mongoose.connection.readyState !== 0) {
      await mongoose.disconnect();
    }
    await mongoose.connect(config.testMongoUri);
    await User.deleteMany({});
  });

  // Clean test collection between test cases to ensure complete test isolation
  afterEach(async () => {
    await User.deleteMany({});
  });

  // Clean up and disconnect after all tests complete
  after(async () => {
    await User.deleteMany({});
    await mongoose.connection.close();
  });

  // ---------------------------------------------------------------------------
  // 1. User Registration Tests
  // ---------------------------------------------------------------------------
  describe('POST /api/v1/auth/register', () => {
    it('should register a new user successfully and return JWT token', async () => {
      const payload = {
        name: 'Aanya Verma',
        email: 'aanya.verma@example.com',
        password: 'SecurePassword123!',
        age: 24
      };

      const res = await request(app)
        .post('/api/v1/auth/register')
        .send(payload)
        .expect(201);

      assert.equal(res.body.success, true);
      assert.equal(res.body.message, 'User registered successfully');
      assert.ok(res.body.data.token, 'Must return an authentication token');
      assert.equal(res.body.data.email, 'aanya.verma@example.com');
      assert.equal(res.body.data.name, 'Aanya Verma');
      assert.equal(res.body.data.onboardingCompleted, false);

      // Verify NO password or password hash is returned in response
      assert.equal(res.body.data.password, undefined, 'Must not return password in response');
      assert.equal(res.body.data.hash, undefined, 'Must not return hash in response');

      // Verify in database that password was hashed with bcrypt
      const savedUser = await User.findOne({ email: 'aanya.verma@example.com' }).select('+password');
      assert.ok(savedUser, 'User must exist in database');
      assert.notEqual(savedUser.password, 'SecurePassword123!', 'Password must NOT be plaintext');
      assert.match(savedUser.password, /^\$2[aby]\$\d+\$/, 'Password must be valid bcrypt hash');
    });

    it('should reject registration when email is already registered (case-insensitive)', async () => {
      // First registration
      await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Aanya Verma',
          email: 'duplicate.user@example.com',
          password: 'Password123@'
        })
        .expect(201);

      // Duplicate attempt with uppercase variation
      const duplicateRes = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Another Name',
          email: 'DUPLICATE.USER@EXAMPLE.COM',
          password: 'AnotherPassword456#'
        })
        .expect(409);

      assert.equal(duplicateRes.body.success, false);
      assert.equal(duplicateRes.body.error.code, 'DUPLICATE_EMAIL');
      assert.match(duplicateRes.body.error.message, /already exists/i);
    });

    it('should reject registration with invalid email format', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Test User',
          email: 'not-an-email',
          password: 'Password123@'
        })
        .expect(422);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
      assert.ok(res.body.error.details.some(d => d.field === 'email'));
    });

    it('should reject registration with weak password (missing special char or number)', async () => {
      // Missing number & special char
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Test User',
          email: 'weak.password@example.com',
          password: 'onlylettershere'
        })
        .expect(422);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
      assert.ok(res.body.error.details.some(d => d.field === 'password'));
    });

    it('should reject registration with name shorter than 2 characters', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'A',
          email: 'short.name@example.com',
          password: 'Password123@'
        })
        .expect(422);

      assert.equal(res.body.success, false);
      assert.ok(res.body.error.details.some(d => d.field === 'name'));
    });

    it('should reject registration with invalid age (below 13)', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Young User',
          email: 'underage@example.com',
          password: 'Password123@',
          age: 10
        })
        .expect(422);

      assert.equal(res.body.success, false);
      assert.ok(res.body.error.details.some(d => d.field === 'age'));
    });
  });

  // ---------------------------------------------------------------------------
  // 2. User Login Tests
  // ---------------------------------------------------------------------------
  describe('POST /api/v1/auth/login', () => {
    beforeEach(async () => {
      // Create a test user for login scenarios
      await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Login Tester',
          email: 'login.test@example.com',
          password: 'ValidPassword123!'
        });
    });

    it('should login successfully with valid credentials and return JWT', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'login.test@example.com',
          password: 'ValidPassword123!'
        })
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.message, 'Login successful');
      assert.ok(res.body.data.token, 'Must return JWT token');
      assert.equal(res.body.data.email, 'login.test@example.com');
      assert.equal(res.body.data.name, 'Login Tester');
    });

    it('should reject login with incorrect password using generic error message', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'login.test@example.com',
          password: 'WrongPassword999#'
        })
        .expect(401);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'INVALID_CREDENTIALS');
      // Generic message must not reveal whether password was wrong vs account missing
      assert.equal(res.body.error.message, 'Invalid email or password.');
    });

    it('should reject login for non-existent email using identical generic error message', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'nonexistent.user@example.com',
          password: 'SomePassword123!'
        })
        .expect(401);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'INVALID_CREDENTIALS');
      assert.equal(res.body.error.message, 'Invalid email or password.');
    });

    it('should reject login with empty or malformed body', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: '',
          password: ''
        })
        .expect(422);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Protected Route Access Tests (GET /api/v1/auth/me)
  // ---------------------------------------------------------------------------
  describe('GET /api/v1/auth/me', () => {
    let validToken;
    let registeredEmail = 'me.test@example.com';

    beforeEach(async () => {
      const reg = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Me Profile User',
          email: registeredEmail,
          password: 'ProfilePassword123!',
          age: 26
        });
      validToken = reg.body.data.token;
    });

    it('should allow access with valid Bearer token and return profile', async () => {
      const res = await request(app)
        .get('/api/v1/auth/me')
        .set('Authorization', `Bearer ${validToken}`)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.message, 'User profile retrieved');
      assert.equal(res.body.data.email, registeredEmail);
      assert.equal(res.body.data.name, 'Me Profile User');
      assert.equal(res.body.data.age, 26);
      assert.equal(res.body.data.password, undefined);
    });

    it('should deny access when Authorization header is missing', async () => {
      const res = await request(app)
        .get('/api/v1/auth/me')
        .expect(401);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'UNAUTHORIZED');
      assert.match(res.body.error.message, /token is required/i);
    });

    it('should deny access when Authorization header is malformed', async () => {
      const res = await request(app)
        .get('/api/v1/auth/me')
        .set('Authorization', 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=')
        .expect(401);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'UNAUTHORIZED');
    });

    it('should deny access when token has invalid signature', async () => {
      const fakeToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NSJ9.invalidSignature';

      const res = await request(app)
        .get('/api/v1/auth/me')
        .set('Authorization', `Bearer ${fakeToken}`)
        .expect(401);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'UNAUTHORIZED');
      assert.match(res.body.error.message, /invalid authentication token/i);
    });

    it('should deny access when token has expired', async () => {
      const jwt = require('jsonwebtoken');
      // Sign a token that has already expired
      const expiredToken = jwt.sign(
        { userId: '671a9101f82c4a001a111111', email: registeredEmail },
        config.jwtSecret,
        { expiresIn: '-1s' }
      );

      const res = await request(app)
        .get('/api/v1/auth/me')
        .set('Authorization', `Bearer ${expiredToken}`)
        .expect(401);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'UNAUTHORIZED');
      assert.match(res.body.error.message, /token has expired/i);
    });
  });

  // ---------------------------------------------------------------------------
  // 4. Duplicate Key Race Condition & Error Handler Security Tests
  // ---------------------------------------------------------------------------
  describe('Duplicate Key Race Condition (code 11000)', () => {
    it('should format MongoDB code 11000 duplicate key error as safe 409 DUPLICATE_EMAIL', () => {
      const { errorHandler } = require('../src/middleware/errorHandler');

      // Simulate a code 11000 MongoServerError
      const mongoDuplicateError = new Error('E11000 duplicate key error collection: hersignal.users index: email_1 dup key: { email: "race@example.com" }');
      mongoDuplicateError.code = 11000;

      let capturedStatus = null;
      let capturedJson = null;

      const mockRes = {
        status(code) {
          capturedStatus = code;
          return this;
        },
        json(payload) {
          capturedJson = payload;
          return this;
        }
      };

      errorHandler(mongoDuplicateError, { method: 'POST', originalUrl: '/api/v1/auth/register' }, mockRes, () => {});

      assert.equal(capturedStatus, 409);
      assert.equal(capturedJson.success, false);
      assert.equal(capturedJson.error.code, 'DUPLICATE_EMAIL');
      assert.equal(capturedJson.error.message, 'An account with this email address already exists.');
      assert.ok(Array.isArray(capturedJson.error.details));
      assert.equal(capturedJson.error.details[0].field, 'email');
      // Verify database internals (E11000, collection names) are NOT exposed
      assert.equal(/E11000/.test(JSON.stringify(capturedJson)), false);
    });
  });

  // ---------------------------------------------------------------------------
  // 5. Production Environment Security Validation Tests
  // ---------------------------------------------------------------------------
  describe('Production Environment Security Validation', () => {
    it('should fail safely in production when JWT_SECRET is missing or a development placeholder', () => {
      const { validateEnv } = require('../src/config/env');

      // Fails on missing secret
      assert.throws(() => {
        validateEnv({ nodeEnv: 'production', jwtSecret: '' });
      }, /Security Error/);

      // Fails on development placeholder
      assert.throws(() => {
        validateEnv({ nodeEnv: 'production', jwtSecret: 'dev_jwt_secret_placeholder' });
      }, /Security Error/);

      // Succeeds on valid, strong custom secret in production
      assert.doesNotThrow(() => {
        validateEnv({
          nodeEnv: 'production',
          jwtSecret: 'a_very_strong_custom_production_secret_key_12345!',
          corsOrigin: 'https://app.inhercue.example.com'
        });
      });

      // Preserves normal development workflow with default placeholder
      assert.doesNotThrow(() => {
        validateEnv({ nodeEnv: 'development', jwtSecret: 'dev_jwt_secret_placeholder' });
      });
    });
  });
});
