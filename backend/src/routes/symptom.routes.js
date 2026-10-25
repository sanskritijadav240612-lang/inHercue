/**
 * Symptom & Daily Check-in Routes for HerSignal API.
 */
const express = require('express');
const { saveCheckin, getHistory, getLatest } = require('../controllers/symptom.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(authenticate);

// POST /api/v1/symptoms/check-in and /checkin
router.post('/check-in', saveCheckin);
router.post('/checkin', saveCheckin);

// GET /api/v1/symptoms/history, /latest, and /
router.get('/history', getHistory);
router.get('/latest', getLatest);
router.get('/', getHistory);

module.exports = router;
