import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { ArrowRight, Sparkles } from 'lucide-react';
import { dimensions } from '../data/dimensions';
import DimensionSlider from './DimensionSlider';
import { generateSignatureFromSliders, generateFullProfile, saveProfile } from '../utils/scoring';

const QuickProfile = ({ onProfileComplete }) => {
  const navigate = useNavigate();
  const [sliderValues, setSliderValues] = useState(() => {
    const initial = {};
    dimensions.forEach((dim) => {
      initial[dim.id] = 5;
    });
    return initial;
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSliderChange = (dimensionId, value) => {
    setSliderValues((prev) => ({
      ...prev,
      [dimensionId]: value,
    }));
  };

  const handleSubmit = () => {
    setIsSubmitting(true);
    const scores = generateSignatureFromSliders(sliderValues);
    const profile = generateFullProfile(scores);
    profile.assessmentType = 'quick';
    profile.timestamp = new Date().toISOString();
    saveProfile(profile);
    if (onProfileComplete) {
      onProfileComplete(profile);
    }
    setTimeout(() => {
      navigate('/results', { state: { profile } });
    }, 600);
  };

  const adjustedCount = Object.values(sliderValues).filter((v) => v !== 5).length;
  const progress = (adjustedCount / 7) * 100;

  return (
    <div
      style={{
        minHeight: '100vh',
        background: '#FAFAF8',
        paddingTop: '6rem',
        paddingBottom: '4rem',
      }}
    >
      <div style={{ maxWidth: '720px', margin: '0 auto', padding: '0 1.5rem' }}>
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          style={{ textAlign: 'center', marginBottom: '3rem' }}
        >
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '0.5rem',
              background: 'linear-gradient(135deg, #C5A05920, #C5A05910)',
              padding: '0.5rem 1rem',
              borderRadius: '24px',
              marginBottom: '1.5rem',
            }}
          >
            <Sparkles size={14} color="#C5A059" />
            <span
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.75rem',
                fontWeight: 600,
                color: '#C5A059',
                textTransform: 'uppercase',
                letterSpacing: '0.1em',
              }}
            >
              Quick Profile — 2 Minutes
            </span>
          </div>

          <h1
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '2.8rem',
              fontWeight: 300,
              color: '#1A1A2E',
              lineHeight: 1.15,
              marginBottom: '1rem',
            }}
          >
            Discover Your{' '}
            <span style={{ fontWeight: 600 }}>Cognitive Style</span>
          </h1>
          <p
            style={{
              fontFamily: "'Manrope', sans-serif",
              fontSize: '1rem',
              color: '#5A5A72',
              lineHeight: 1.7,
              maxWidth: '540px',
              margin: '0 auto',
            }}
          >
            Position yourself on each of the seven dimensions of cognitive style.
            There are no right or wrong answers — each position reflects a
            different kind of intelligence.
          </p>
        </motion.div>

        {/* Progress bar */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3 }}
          style={{ marginBottom: '2.5rem' }}
        >
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              marginBottom: '0.5rem',
            }}
          >
            <span
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.75rem',
                color: '#8E8EA0',
              }}
            >
              {adjustedCount} of 7 dimensions adjusted
            </span>
            <span
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.75rem',
                color: '#8E8EA0',
              }}
            >
              {Math.round(progress)}%
            </span>
          </div>
          <div
            style={{
              height: '3px',
              background: '#E8E8EC',
              borderRadius: '2px',
              overflow: 'hidden',
            }}
          >
            <motion.div
              animate={{ width: `${progress}%` }}
              transition={{ duration: 0.4, ease: 'easeOut' }}
              style={{
                height: '100%',
                background:
                  'linear-gradient(90deg, #4FC3F7, #FFB74D, #66BB6A, #AB47BC, #EF5350, #26A69A, #5C6BC0)',
                borderRadius: '2px',
              }}
            />
          </div>
        </motion.div>

        {/* Dimension sliders */}
        <div style={{ marginBottom: '3rem' }}>
          {dimensions.map((dim, index) => (
            <motion.div
              key={dim.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: 0.1 + index * 0.08 }}
            >
              <DimensionSlider
                dimension={dim}
                value={sliderValues[dim.id]}
                onChange={(val) => handleSliderChange(dim.id, val)}
                showDescription={true}
              />
            </motion.div>
          ))}
        </div>

        {/* Submit button */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          style={{ textAlign: 'center' }}
        >
          <AnimatePresence>
            {isSubmitting ? (
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '0.75rem',
                  padding: '1rem 2rem',
                }}
              >
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                  style={{
                    width: 20,
                    height: 20,
                    border: '2px solid #C5A059',
                    borderTopColor: 'transparent',
                    borderRadius: '50%',
                  }}
                />
                <span
                  style={{
                    fontFamily: "'Manrope', sans-serif",
                    color: '#C5A059',
                    fontWeight: 600,
                  }}
                >
                  Generating your Cognitive Signature...
                </span>
              </motion.div>
            ) : (
              <motion.button
                whileHover={{ scale: 1.02, y: -2 }}
                whileTap={{ scale: 0.98 }}
                onClick={handleSubmit}
                style={{
                  fontFamily: "'Manrope', sans-serif",
                  fontSize: '1rem',
                  fontWeight: 600,
                  color: '#FFFFFF',
                  background:
                    'linear-gradient(135deg, #1A1A2E, #2D1B4E)',
                  border: 'none',
                  padding: '1rem 2.5rem',
                  borderRadius: '12px',
                  cursor: 'pointer',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '0.75rem',
                  boxShadow: '0 4px 20px rgba(26, 26, 46, 0.3)',
                  transition: 'box-shadow 0.3s ease',
                }}
              >
                See Your Profile
                <ArrowRight size={18} />
              </motion.button>
            )}
          </AnimatePresence>

          <p
            style={{
              fontFamily: "'Manrope', sans-serif",
              fontSize: '0.8rem',
              color: '#8E8EA0',
              marginTop: '1.5rem',
            }}
          >
            Want more accuracy?{' '}
            <span
              onClick={() => navigate('/assessment')}
              style={{
                color: '#C5A059',
                cursor: 'pointer',
                fontWeight: 600,
              }}
            >
              Take the full 35-question assessment
            </span>
          </p>
        </motion.div>
      </div>
    </div>
  );
};

export default QuickProfile;
