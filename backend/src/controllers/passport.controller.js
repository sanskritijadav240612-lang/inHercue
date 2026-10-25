/**
 * Health Passport Controller for HerSignal API.
 * Manages user baseline health profile and onboarding preferences with strict user scoping.
 */
const HealthPassport = require('../models/passport.model');
const User = require('../models/user.model');

/**
 * Get the authenticated user's health passport.
 * GET /api/v1/passport
 */
async function getPassport(req, res, next) {
  try {
    const passport = await HealthPassport.findOne({ userId: req.user._id });

    if (!passport) {
      return res.status(200).json({
        success: true,
        message: 'Health passport not yet initialized',
        data: null
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Health passport retrieved',
      data: passport
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Upsert the authenticated user's health passport.
 * PUT /api/v1/passport or POST /api/v1/passport
 */
async function upsertPassport(req, res, next) {
  try {
    const {
      focus,
      cycleType,
      bloodGroup,
      averageCycleDays,
      typicalPeriodDurationDays,
      lastPeriodStartDate,
      diagnosedConditions,
      allergies,
      currentMedications,
      emergencyContacts
    } = req.body;

    const updateData = {};
    if (focus !== undefined) updateData.focus = focus;
    if (cycleType !== undefined) updateData.cycleType = cycleType;
    if (bloodGroup !== undefined) updateData.bloodGroup = bloodGroup;
    if (averageCycleDays !== undefined) updateData.averageCycleDays = Number(averageCycleDays);
    if (typicalPeriodDurationDays !== undefined) updateData.typicalPeriodDurationDays = Number(typicalPeriodDurationDays);
    if (lastPeriodStartDate !== undefined) updateData.lastPeriodStartDate = lastPeriodStartDate;
    if (Array.isArray(diagnosedConditions)) updateData.diagnosedConditions = diagnosedConditions;
    if (Array.isArray(allergies)) updateData.allergies = allergies;
    if (Array.isArray(currentMedications)) updateData.currentMedications = currentMedications;
    if (Array.isArray(emergencyContacts)) updateData.emergencyContacts = emergencyContacts;

    const passport = await HealthPassport.findOneAndUpdate(
      { userId: req.user._id },
      { $set: updateData },
      { upsert: true, new: true, runValidators: true, setDefaultsOnInsert: true }
    );

    // Mark onboarding completed on user account
    if (!req.user.onboardingCompleted) {
      await User.findByIdAndUpdate(req.user._id, { onboardingCompleted: true });
    }

    return res.status(200).json({
      success: true,
      message: 'Health passport saved successfully',
      data: passport
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getPassport,
  upsertPassport
};
