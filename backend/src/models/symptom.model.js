/**
 * Symptom Check-in Mongoose Model for HerSignal.
 * Stores authenticated user daily symptom logs, flow ratings, lifestyle metrics,
 * and deterministic safety triage evaluations.
 */
const mongoose = require('mongoose');

const symptomItemSchema = new mongoose.Schema(
  {
    type: { type: String, required: true, trim: true },
    severity: {
      type: String,
      enum: ['mild', 'moderate', 'severe', 'low', 'high', 'none', ''],
      default: 'mild'
    },
    duration: { type: String, trim: true, default: '' },
    frequency: { type: String, trim: true, default: '' }
  },
  { _id: false }
);

const symptomSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    date: {
      type: String,
      required: true,
      trim: true
    },
    flow: {
      type: String,
      trim: true,
      default: 'none'
    },
    painScale: {
      type: Number,
      min: 0,
      max: 10,
      default: 0
    },
    symptoms: {
      type: [symptomItemSchema],
      default: []
    },
    hydration: {
      type: String,
      trim: true,
      default: null
    },
    sleep: {
      type: String,
      trim: true,
      default: null
    },
    energy: {
      type: String,
      trim: true,
      default: null
    },
    activity: {
      type: String,
      trim: true,
      default: null
    },
    appetite: {
      type: String,
      trim: true,
      default: null
    },
    mood: {
      type: String,
      trim: true,
      default: null
    },
    notes: {
      type: String,
      trim: true,
      default: ''
    },
    safetyAssessment: {
      isEmergency: { type: Boolean, default: false },
      triageLevel: { type: String, default: 'ROUTINE' },
      advice: { type: String, default: 'Routine self-care applies.' }
    }
  },
  {
    timestamps: true
  }
);

// Composite index for fast date querying per user
symptomSchema.index({ userId: 1, date: -1 });

const SymptomLog = mongoose.model('SymptomLog', symptomSchema);

module.exports = SymptomLog;
