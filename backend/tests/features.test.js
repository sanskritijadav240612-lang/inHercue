/**
 * Automated tests for HerSignal Health Passport, Symptoms Check-in, and Safety Triage.
 */
const { describe, it, before, after } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const mongoose = require('mongoose');

const app = require('../src/app');
const config = require('../src/config/env');
const User = require('../src/models/user.model');
const HealthPassport = require('../src/models/passport.model');
const SymptomLog = require('../src/models/symptom.model');

describe('HerSignal API - Health Passport, Symptoms & Safety Triage Tests', () => {
  let userAToken;
  let userBToken;
  let userAId;

  before(async () => {
    if (mongoose.connection.readyState !== 0) {
      await mongoose.disconnect();
    }
    await mongoose.connect(config.testMongoUri + '_features');
    await User.deleteMany({});
    await HealthPassport.deleteMany({});
    await SymptomLog.deleteMany({});

    // Register User A
    const resA = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'User A',
        email: 'usera@example.com',
        password: 'Password123!',
        age: 25
      });
    userAToken = resA.body.data.token;
    userAId = resA.body.data.userId;

    // Register User B
    const resB = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'User B',
        email: 'userb@example.com',
        password: 'Password123!',
        age: 28
      });
    userBToken = resB.body.data.token;
  });

  after(async () => {
    await User.deleteMany({});
    await HealthPassport.deleteMany({});
    await SymptomLog.deleteMany({});
    await mongoose.connection.close();
  });

  // ---------------------------------------------------------------------------
  // 1. Health Passport Tests
  // ---------------------------------------------------------------------------
  describe('Health Passport Module', () => {
    it('GET /api/v1/passport should reject unauthenticated request with 401', async () => {
      const res = await request(app).get('/api/v1/passport').expect(401);
      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'UNAUTHORIZED');
    });

    it('GET /api/v1/passport should return null data before passport is saved', async () => {
      const res = await request(app)
        .get('/api/v1/passport')
        .set('Authorization', `Bearer ${userAToken}`)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data, null);
    });

    it('PUT /api/v1/passport should save and return user health passport', async () => {
      const payload = {
        focus: 'Cycle tracking & rhythm',
        cycleType: 'Regular (26–32 days)',
        averageCycleDays: 29,
        typicalPeriodDurationDays: 5,
        diagnosedConditions: ['PCOS'],
        allergies: ['Penicillin'],
        emergencyContacts: [
          { name: 'Dr. Jane', relationship: 'Physician', phone: '+1-555-0199' }
        ]
      };

      const res = await request(app)
        .put('/api/v1/passport')
        .set('Authorization', `Bearer ${userAToken}`)
        .send(payload)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data.averageCycleDays, 29);
      assert.equal(res.body.data.focus, 'Cycle tracking & rhythm');
      assert.deepEqual(res.body.data.diagnosedConditions, ['PCOS']);

      // Verify User record now has onboardingCompleted = true
      const updatedUser = await User.findById(userAId);
      assert.equal(updatedUser.onboardingCompleted, true);
    });

    it('GET /api/v1/passport should retrieve saved passport for User A', async () => {
      const res = await request(app)
        .get('/api/v1/passport')
        .set('Authorization', `Bearer ${userAToken}`)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data.averageCycleDays, 29);
      assert.equal(res.body.data.diagnosedConditions[0], 'PCOS');
    });

    it('GET /api/v1/passport should maintain tenant boundary (User B does not see User A passport)', async () => {
      const res = await request(app)
        .get('/api/v1/passport')
        .set('Authorization', `Bearer ${userBToken}`)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data, null);
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Symptom Check-in & History Tests
  // ---------------------------------------------------------------------------
  describe('Symptom Check-in Module', () => {
    it('POST /api/v1/symptoms/check-in should reject unauthenticated request with 401', async () => {
      const res = await request(app).post('/api/v1/symptoms/check-in').send({}).expect(401);
      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'UNAUTHORIZED');
    });

    it('POST /api/v1/symptoms/check-in should save check-in and return safetyAssessment', async () => {
      const checkinPayload = {
        date: '2026-10-25',
        flow: 'medium',
        painScale: 3,
        symptoms: [
          { type: 'Cramps', severity: 'moderate' },
          { type: 'Headache', severity: 'mild' }
        ],
        hydration: '1-2L',
        sleep: 'Restful',
        mood: 'Calm & steady',
        notes: 'Feeling good overall after walk.'
      };

      const res = await request(app)
        .post('/api/v1/symptoms/check-in')
        .set('Authorization', `Bearer ${userAToken}`)
        .send(checkinPayload)
        .expect(201);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data.date, '2026-10-25');
      assert.ok(res.body.data.safetyAssessment);
      assert.equal(res.body.data.safetyAssessment.isEmergency, false);
      assert.equal(res.body.data.safetyAssessment.triageLevel, 'ROUTINE');
    });

    it('GET /api/v1/symptoms/history should return list of saved symptoms for User A', async () => {
      const res = await request(app)
        .get('/api/v1/symptoms/history')
        .set('Authorization', `Bearer ${userAToken}`)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data.count, 1);
      assert.equal(res.body.data.logs[0].date, '2026-10-25');
      assert.equal(res.body.data.logs[0].flow, 'medium');
    });

    it('GET /api/v1/symptoms/latest should return the most recent check-in', async () => {
      const res = await request(app)
        .get('/api/v1/symptoms/latest')
        .set('Authorization', `Bearer ${userAToken}`)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.ok(res.body.data);
      assert.equal(res.body.data.date, '2026-10-25');
    });

    it('GET /api/v1/symptoms/history should enforce user isolation (User B has 0 logs)', async () => {
      const res = await request(app)
        .get('/api/v1/symptoms/history')
        .set('Authorization', `Bearer ${userBToken}`)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data.count, 0);
      assert.equal(res.body.data.logs.length, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Deterministic Safety Triage Tests
  // ---------------------------------------------------------------------------
  describe('Safety & Urgent Care Triage Module', () => {
    it('POST /api/v1/safety/triage should return EMERGENCY_RED_FLAG when acute red-flag indicators are met', async () => {
      const res = await request(app)
        .post('/api/v1/safety/triage')
        .send({
          acuteSymptoms: ['severe_lower_abdominal_pain', 'fainting_or_dizziness'],
          painScale: 9,
          bleedingRate: 'soaking_two_pads_an_hour'
        })
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data.isRedFlag, true);
      assert.equal(res.body.data.triageLevel, 'EMERGENCY_RED_FLAG');
      assert.match(res.body.data.alertHeadline, /URGENT MEDICAL EVALUATION/i);
      assert.match(res.body.data.actionRequired, /seek emergency medical attention/i);
      assert.ok(res.body.data.recommendedSteps.length > 0);
      assert.ok(res.body.data.disclaimer);
    });

    it('POST /api/v1/safety/triage should return ROUTINE for non-red-flag symptoms', async () => {
      const res = await request(app)
        .post('/api/v1/safety/triage')
        .send({
          acuteSymptoms: ['mild_bloating', 'tiredness'],
          painScale: 2
        })
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(res.body.data.isRedFlag, false);
      assert.equal(res.body.data.triageLevel, 'ROUTINE');
      assert.match(res.body.data.alertHeadline, /NO ACUTE RED FLAGS/i);
    });
  });
});
