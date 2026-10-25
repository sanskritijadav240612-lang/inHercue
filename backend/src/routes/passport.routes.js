/**
 * Health Passport Routes for HerSignal API.
 */
const express = require('express');
const { getPassport, upsertPassport } = require('../controllers/passport.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(authenticate);

router.get('/', getPassport);
router.put('/', upsertPassport);
router.post('/', upsertPassport);

module.exports = router;
