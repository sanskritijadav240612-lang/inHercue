/**
 * Safety & Urgent Care Routes for HerSignal API.
 */
const express = require('express');
const { triage } = require('../controllers/safety.controller');

const router = express.Router();

// POST /api/v1/safety/triage (Accessible publicly or with token so crisis help is never blocked)
router.post('/triage', triage);

module.exports = router;
