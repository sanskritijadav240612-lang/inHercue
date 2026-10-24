/**
 * Automated tests for HerSignal Health Check Endpoint.
 * Uses Node.js built-in test runner with Supertest for HTTP assertions.
 */
const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const app = require('../src/app');

describe('HerSignal API - Health & Foundation Tests', () => {

  it('GET /api/v1/health should return 200 and operational status', async () => {
    const response = await request(app)
      .get('/api/v1/health')
      .expect(200);

    // Verify response envelope adheres to API contract
    assert.equal(response.body.success, true);
    assert.equal(response.body.message, 'HerSignal API is operational');
    assert.ok(response.body.data, 'Response should contain data payload');

    const data = response.body.data;
    assert.equal(data.service, 'HerSignal API');
    assert.equal(data.status, 'healthy');
    assert.equal(data.version, '1.0.0');
    assert.ok(data.timestamp, 'Timestamp must be provided');
    assert.ok(data.environment, 'Environment must be provided');

    // Verify database status is reported accurately without leaking credentials
    assert.ok(typeof data.database === 'object', 'Database info must be an object');
    assert.ok(typeof data.database.connected === 'boolean', 'Database connected must be boolean');
    assert.ok(typeof data.database.status === 'string', 'Database status must be string');

    // Ensure no secrets or connection strings are exposed
    assert.equal(data.database.mongoUri, undefined, 'Must not leak database URI');
    assert.equal(data.database.password, undefined, 'Must not leak database credentials');
    assert.equal(data.jwtSecret, undefined, 'Must not leak JWT secret');
  });

  it('GET / should return 200 with welcome message', async () => {
    const response = await request(app)
      .get('/')
      .expect(200);

    assert.equal(response.body.success, true);
    assert.match(response.body.message, /HerSignal API/i);
  });

  it('GET /api/v1/unknown-route should return 404 with standard error envelope', async () => {
    const response = await request(app)
      .get('/api/v1/unknown-route')
      .expect(404);

    assert.equal(response.body.success, false);
    assert.ok(response.body.error);
    assert.equal(response.body.error.code, 'NOT_FOUND');
    assert.match(response.body.error.message, /does not exist/i);
  });

});
