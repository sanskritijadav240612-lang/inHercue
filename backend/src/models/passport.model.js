/**
 * Health Passport Mongoose Model for HerSignal.
 * Stores user-controlled baseline health metrics, cycle parameters,
 * diagnosed conditions, and emergency contacts.
 */
const mongoose = require('mongoose');

const emergencyContactSchema = new mongoose.Schema(
  {
    name: { type: String, trim: true },
    relationship: { type: String, trim: true },
    phone: { type: String, trim: true }
  },
  { _id: false }
);

const passportSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
      index: true
    },
    focus: {
      type: String,
      trim: true,
      default: 'Cycle tracking & rhythm'
    },
    cycleType: {
      type: String,
      trim: true,
      default: 'Regular (26–32 days)'
    },
    bloodGroup: {
      type: String,
      trim: true,
      default: null
    },
    averageCycleDays: {
      type: Number,
      min: 15,
      max: 90,
      default: 28
    },
    typicalPeriodDurationDays: {
      type: Number,
      min: 1,
      max: 20,
      default: 5
    },
    lastPeriodStartDate: {
      type: String,
      trim: true,
      default: null
    },
    diagnosedConditions: {
      type: [String],
      default: []
    },
    allergies: {
      type: [String],
      default: []
    },
    currentMedications: {
      type: [String],
      default: []
    },
    emergencyContacts: {
      type: [emergencyContactSchema],
      default: []
    }
  },
  {
    timestamps: true
  }
);

const HealthPassport = mongoose.model('HealthPassport', passportSchema);

module.exports = HealthPassport;
