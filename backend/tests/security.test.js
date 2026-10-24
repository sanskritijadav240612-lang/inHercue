/**
 * Automated Security Tests for inHERcue API.
 * Covers:
 * 1. Authentication Rate Limiting (Login & Registration thresholds, 429 responses, error envelope)
 * 2. Rate-limit standard headers (draft-7 headers)
 * 3. Safe CORS allowlist enforcement, non-browser clients, and untrusted origin rejection
 * 4. Isolation & fast execution without real-time waiting
 */
const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const express = require('express');
const cors = require('cors');

const app = require('../src/app');
const { createAuthRateLimiter, createRateLimitHandler } = require('../src/middleware/rateLimiter');
const { createCorsOptions, isOriginAllowed, getParsedOrigins } = require('../src/config/cors');
const { validateEnv } = require('../src/config/env');

describe('inHERcue Security - Rate Limiting & Safe CORS Tests', () => {

  // ===========================================================================
  // 1. Rate Limiting Tests (Using isolated testable limiter instances)
  // ===========================================================================
  describe('Authentication Rate Limiting', () => {

    it('should return HTTP 429 with RATE_LIMIT_EXCEEDED when threshold is exceeded', async () => {
      // Create a test app with an isolated fast-threshold limiter (max 3 requests)
      const testApp = express();
      testApp.use(express.json());

      const testLimiter = createAuthRateLimiter({
        windowMs: 60 * 1000,
        max: 3,
        message: 'Too many login attempts. Cooldown active.'
      });

      testApp.post('/api/v1/auth/test-login', testLimiter, (req, res) => {
        res.status(200).json({ success: true, message: 'Login allowed' });
      });

      // Request 1: Allowed (remaining 2)
      const res1 = await request(testApp).post('/api/v1/auth/test-login').send({});
      assert.equal(res1.status, 200);

      // Request 2: Allowed (remaining 1)
      const res2 = await request(testApp).post('/api/v1/auth/test-login').send({});
      assert.equal(res2.status, 200);

      // Request 3: Allowed (remaining 0)
      const res3 = await request(testApp).post('/api/v1/auth/test-login').send({});
      assert.equal(res3.status, 200);

      // Request 4: Throttled (exceeded limit -> 429)
      const res4 = await request(testApp).post('/api/v1/auth/test-login').send({});
      assert.equal(res4.status, 429);
      assert.equal(res4.body.success, false);
      assert.equal(res4.body.error.code, 'RATE_LIMIT_EXCEEDED');
      assert.match(res4.body.error.message, /Too many login attempts/);
      assert.ok(Array.isArray(res4.body.error.details));
      assert.equal(res4.body.error.details.length, 0);

      // Verify draft-7 standard RateLimit headers are emitted
      assert.ok(
        res4.headers['ratelimit-limit'] !== undefined ||
        res4.headers['ratelimit-policy'] !== undefined,
        'Should include draft-7 RateLimit headers'
      );
      // Deprecated X-RateLimit-* headers should be disabled
      assert.equal(res4.headers['x-ratelimit-limit'], undefined);
    });

    it('should throttle registration attempts after 3 requests on test limiter', async () => {
      const testApp = express();
      testApp.use(express.json());

      const regLimiter = createAuthRateLimiter({
        windowMs: 60 * 1000,
        max: 3,
        message: 'Too many registration attempts. Please try again after an hour.'
      });

      testApp.post('/api/v1/auth/test-reg', regLimiter, (req, res) => {
        res.status(201).json({ success: true, message: 'Account created' });
      });

      // 3 allowed attempts
      await request(testApp).post('/api/v1/auth/test-reg').send({}).expect(201);
      await request(testApp).post('/api/v1/auth/test-reg').send({}).expect(201);
      await request(testApp).post('/api/v1/auth/test-reg').send({}).expect(201);

      // 4th attempt is throttled
      const throttled = await request(testApp)
        .post('/api/v1/auth/test-reg')
        .send({})
        .expect(429);

      assert.equal(throttled.body.success, false);
      assert.equal(throttled.body.error.code, 'RATE_LIMIT_EXCEEDED');
      assert.match(throttled.body.error.message, /Too many registration attempts/);
    });

    it('should verify standard app route /api/v1/auth/login hits rate limiter and headers', async () => {
      // Normal requests below limit reach the route validation (returning 422 for empty payload)
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({});

      assert.equal(res.status, 422); // Reached validateLogin
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');

      // Verify RateLimit headers are attached by loginLimiter
      assert.ok(
        res.headers['ratelimit-limit'] !== undefined ||
        res.headers['ratelimit-policy'] !== undefined,
        'Active login route must include RateLimit headers'
      );
    });

    it('should verify standard app route /api/v1/auth/register hits rate limiter and headers', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({});

      assert.equal(res.status, 422); // Reached validateRegister
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');

      // Verify RateLimit headers are attached by registerLimiter
      assert.ok(
        res.headers['ratelimit-limit'] !== undefined ||
        res.headers['ratelimit-policy'] !== undefined,
        'Active register route must include RateLimit headers'
      );
    });
  });

  // ===========================================================================
  // 2. Safe CORS Configuration Tests
  // ===========================================================================
  describe('Safe CORS Configuration', () => {

    it('should permit non-browser requests without Origin header (Flutter mobile apps, curl)', () => {
      const allowed = isOriginAllowed(undefined, ['https://app.inhercue.com'], false);
      assert.equal(allowed, true, 'Requests with no Origin header must be allowed');
    });

    it('should permit origins in the configured allowlist', () => {
      const allowlist = ['http://localhost:8443', 'https://app.inhercue.com'];
      assert.equal(isOriginAllowed('http://localhost:8443', allowlist, false), true);
      assert.equal(isOriginAllowed('https://app.inhercue.com', allowlist, false), true);
    });

    it('should reject untrusted browser origins in production', () => {
      const allowlist = ['https://app.inhercue.com'];
      assert.equal(isOriginAllowed('https://malicious-site.example', allowlist, false), false);
      assert.equal(isOriginAllowed('http://localhost:8443', allowlist, false), false);
    });

    it('should permit local development localhost/127.0.0.1 on any port in development mode', () => {
      const allowlist = ['http://localhost:3000'];
      assert.equal(isOriginAllowed('http://localhost:8443', allowlist, true), true);
      assert.equal(isOriginAllowed('http://127.0.0.1:53421', allowlist, true), true);
    });

    it('should reject wildcard CORS in production mode within isOriginAllowed', () => {
      // Even if allowlist somehow contains '*', production mode (isDevelopment=false) must reject it
      const allowlist = ['*'];
      assert.equal(isOriginAllowed('https://arbitrary-site.example', allowlist, false), false);
    });

    it('should fail validateEnv in production when CORS_ORIGIN is wildcard or missing', () => {
      const strongJwt = 'a_secure_custom_production_jwt_signing_secret_64chars_long_12345';

      // 1. Rejects wildcard '*'
      assert.throws(() => {
        validateEnv({ nodeEnv: 'production', jwtSecret: strongJwt, corsOrigin: '*' });
      }, /CORS_ORIGIN must be explicitly set/i);

      // 2. Rejects comma-separated list containing '*'
      assert.throws(() => {
        validateEnv({ nodeEnv: 'production', jwtSecret: strongJwt, corsOrigin: 'https://app.inhercue.com, *' });
      }, /CORS_ORIGIN must be explicitly set/i);

      // 3. Rejects empty string
      assert.throws(() => {
        validateEnv({ nodeEnv: 'production', jwtSecret: strongJwt, corsOrigin: '' });
      }, /CORS_ORIGIN must be explicitly set/i);

      // 4. Rejects undefined / null
      assert.throws(() => {
        validateEnv({ nodeEnv: 'production', jwtSecret: strongJwt, corsOrigin: undefined });
      }, /CORS_ORIGIN must be explicitly set/i);

      // 5. Succeeds when explicit trusted origin allowlist is provided
      assert.doesNotThrow(() => {
        validateEnv({ nodeEnv: 'production', jwtSecret: strongJwt, corsOrigin: 'https://app.inhercue.com' });
      });

      // 6. Preserves development compatibility with default wildcard
      assert.doesNotThrow(() => {
        validateEnv({ nodeEnv: 'development', jwtSecret: 'dev_jwt_secret_placeholder', corsOrigin: '*' });
      });
    });

    it('should parse comma-separated CORS_ORIGIN strings correctly', () => {
      const parsed = getParsedOrigins('http://localhost:3000, http://localhost:8443 ,https://preview.inhercue.com');
      assert.deepEqual(parsed, [
        'http://localhost:3000',
        'http://localhost:8443',
        'https://preview.inhercue.com'
      ]);
    });

    it('should block untrusted browser origin with 403 CORS_FORBIDDEN error envelope', async () => {
      // Build a dedicated test app with strict production CORS configuration
      const corsTestApp = express();
      corsTestApp.use(cors(createCorsOptions({
        nodeEnv: 'production',
        corsOrigin: 'https://trusted.inhercue.com'
      })));
      corsTestApp.use(express.json());
      corsTestApp.get('/test-endpoint', (req, res) => res.json({ ok: true }));

      // Global error handler
      const { errorHandler } = require('../src/middleware/errorHandler');
      corsTestApp.use(errorHandler);

      // 1. Trusted origin succeeds
      const trustedRes = await request(corsTestApp)
        .get('/test-endpoint')
        .set('Origin', 'https://trusted.inhercue.com')
        .expect(200);

      assert.equal(trustedRes.headers['access-control-allow-origin'], 'https://trusted.inhercue.com');

      // 2. Untrusted origin is rejected with 403 and error envelope
      const untrustedRes = await request(corsTestApp)
        .get('/test-endpoint')
        .set('Origin', 'https://attacker.evil.com')
        .expect(403);

      assert.equal(untrustedRes.body.success, false);
      assert.equal(untrustedRes.body.error.code, 'CORS_FORBIDDEN');
      assert.match(untrustedRes.body.error.message, /not permitted by CORS policy/i);
    });

    it('should allow Flutter web preview on current app instance', async () => {
      // Current app instance should permit requests from localhost (Vite dev server on 8443)
      const res = await request(app)
        .get('/api/v1/health')
        .set('Origin', 'http://localhost:8443')
        .expect(200);

      assert.equal(res.body.success, true);
    });
  });

  // ===========================================================================
  // 3. Existing Health Check Route Compatibility
  // ===========================================================================
  describe('Health Route Compatibility', () => {
    it('GET /api/v1/health should remain fully compatible and functional', async () => {
      const res = await request(app)
        .get('/api/v1/health')
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data.status, 'healthy');
    });
  });

});
