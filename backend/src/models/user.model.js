/**
 * User Mongoose Model for HerSignal.
 * Implements secure password hashing with bcryptjs and sensitive field protection.
 */
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      minlength: [2, 'Name must be at least 2 characters long'],
      maxlength: [60, 'Name cannot exceed 60 characters']
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [emailRegex, 'Please provide a valid email address']
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: [8, 'Password must be at least 8 characters long'],
      select: false // Never returned in queries by default
    },
    age: {
      type: Number,
      min: [13, 'User must be at least 13 years old'],
      max: [120, 'Age cannot exceed 120'],
      default: null
    },
    onboardingCompleted: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

/**
 * Pre-save middleware to securely hash password before persisting.
 */
userSchema.pre('save', async function (next) {
  // Only hash password if it has been modified (or is new)
  if (!this.isModified('password')) {
    return next();
  }

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

/**
 * Compares candidate plain-text password with stored hash.
 *
 * @param {string} candidatePassword - Plaintext password attempt
 * @returns {Promise<boolean>} True if matching, false otherwise
 */
userSchema.methods.comparePassword = async function (candidatePassword) {
  if (!this.password) {
    return false;
  }
  return bcrypt.compare(candidatePassword, this.password);
};

/**
 * Returns a sanitized plain JavaScript object of the user without password.
 */
userSchema.methods.toSafeObject = function () {
  return {
    userId: this._id,
    name: this.name,
    email: this.email,
    age: this.age,
    onboardingCompleted: this.onboardingCompleted,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt
  };
};

const User = mongoose.model('User', userSchema);

module.exports = User;
