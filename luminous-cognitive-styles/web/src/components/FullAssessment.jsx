import React, { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft,
  ArrowRight,
  Clock,
  Save,
  CheckCircle,
} from 'lucide-react';
import { dimensions, getAllQuestions } from '../data/dimensions';
import {
  calculateAllScores,
  generateFullProfile,
  saveProfile,
  saveDSRProgress,
  loadDSRProgress,
} from '../utils/scoring';

const LikertScale = ({ value, onChange, color }) => {
  const labels = [
    'Strongly Disagree',
    'Disagree',
    'Slightly Disagree',
    'Neutral',
    'Slightly Agree',
    'Agree',
    'Strongly Agree',
  ];

  return (
    <div style={{ marginTop: '1.5rem' }}>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          gap: '0.5rem',
        }}
      >
        {labels.map((label, idx) => {
          const val = idx + 1;
          const isSelected = value === val;
          return (
            <motion.button
              key={val}
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => onChange(val)}
              style={{
                flex: 1,
                padding: '0.75rem 0.25rem',
                border: isSelected ? `2px solid ${color}` : '2px solid #E8E8EC',
                borderRadius: '10px',
                background: isSelected ? `${color}15` : '#FFFFFF',
                cursor: 'pointer',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '0.35rem',
                transition: 'all 0.2s ease',
              }}
            >
              <span
                style={{
                  fontFamily: "'Manrope', sans-serif",
                  fontSize: '1.1rem',
                  fontWeight: 700,
                  color: isSelected ? color : '#5A5A72',
                }}
              >
                {val}
              </span>
              <span
                style={{
                  fontFamily: "'Manrope', sans-serif",
                  fontSize: '0.6rem',
                  color: isSelected ? color : '#8E8EA0',
                  lineHeight: 1.2,
                  textAlign: 'center',
                }}
              >
                {label}
              </span>
            </motion.button>
          );
        })}
      </div>
    </div>
  );
};

const FullAssessment = ({ onProfileComplete }) => {
  const navigate = useNavigate();
  const allQuestions = getAllQuestions();
  const [answers, setAnswers] = useState(() => loadDSRProgress());
  const [currentSection, setCurrentSection] = useState(0);
  const [showSaved, setShowSaved] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const questionsPerSection = 5;
  const totalSections = dimensions.length;

  const currentDimension = dimensions[currentSection];
  const sectionQuestions = allQuestions.filter(
    (q) => q.dimensionId === currentDimension.id
  );

  const answeredInSection = sectionQuestions.filter(
    (q) => answers[q.id] !== undefined
  ).length;
  const totalAnswered = Object.keys(answers).length;
  const totalQuestions = allQuestions.length;
  const overallProgress = (totalAnswered / totalQuestions) * 100;

  const isSectionComplete = answeredInSection === questionsPerSection;
  const isAllComplete = totalAnswered === totalQuestions;

  const handleAnswer = useCallback(
    (questionId, value) => {
      setAnswers((prev) => {
        const updated = { ...prev, [questionId]: value };
        saveDSRProgress(updated);
        return updated;
      });
    },
    []
  );

  const handleSave = () => {
    saveDSRProgress(answers);
    setShowSaved(true);
    setTimeout(() => setShowSaved(false), 2000);
  };

  const handleSubmit = () => {
    setIsSubmitting(true);
    const scores = calculateAllScores(answers);
    const profile = generateFullProfile(scores);
    profile.assessmentType = 'full';
    profile.timestamp = new Date().toISOString();
    saveProfile(profile);
    if (onProfileComplete) {
      onProfileComplete(profile);
    }
    setTimeout(() => {
      navigate('/results', { state: { profile } });
    }, 800);
  };

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }, [currentSection]);

  return (
    <div
      style={{
        minHeight: '100vh',
        background: '#FAFAF8',
        paddingTop: '6rem',
        paddingBottom: '4rem',
      }}
    >
      <div style={{ maxWidth: '780px', margin: '0 auto', padding: '0 1.5rem' }}>
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          style={{ textAlign: 'center', marginBottom: '2rem' }}
        >
          <h1
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '2.2rem',
              fontWeight: 300,
              color: '#1A1A2E',
              marginBottom: '0.5rem',
            }}
          >
            Dimensional Self-Report
          </h1>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '0.5rem',
              color: '#8E8EA0',
            }}
          >
            <Clock size={14} />
            <span
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.8rem',
              }}
            >
              Approximately 15 minutes — 35 questions
            </span>
          </div>
        </motion.div>

        {/* Overall progress */}
        <div style={{ marginBottom: '2rem' }}>
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              marginBottom: '0.4rem',
            }}
          >
            <span
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.75rem',
                color: '#8E8EA0',
              }}
            >
              Overall Progress
            </span>
            <span
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.75rem',
                color: '#8E8EA0',
              }}
            >
              {totalAnswered} / {totalQuestions}
            </span>
          </div>
          <div
            style={{
              height: '4px',
              background: '#E8E8EC',
              borderRadius: '2px',
              overflow: 'hidden',
            }}
          >
            <motion.div
              animate={{ width: `${overallProgress}%` }}
              transition={{ duration: 0.4 }}
              style={{
                height: '100%',
                background:
                  'linear-gradient(90deg, #4FC3F7, #FFB74D, #66BB6A, #AB47BC, #EF5350, #26A69A, #5C6BC0)',
                borderRadius: '2px',
              }}
            />
          </div>
        </div>

        {/* Section tabs */}
        <div
          style={{
            display: 'flex',
            gap: '0.5rem',
            marginBottom: '2rem',
            overflowX: 'auto',
            paddingBottom: '0.25rem',
          }}
        >
          {dimensions.map((dim, idx) => {
            const sectionAnswered = dim.questions.filter(
              (q) => answers[q.id] !== undefined
            ).length;
            const isComplete = sectionAnswered === 5;
            const isCurrent = idx === currentSection;
            return (
              <motion.button
                key={dim.id}
                whileHover={{ scale: 1.03 }}
                whileTap={{ scale: 0.97 }}
                onClick={() => setCurrentSection(idx)}
                style={{
                  padding: '0.5rem 0.85rem',
                  borderRadius: '8px',
                  border: isCurrent
                    ? `2px solid ${dim.color}`
                    : '2px solid transparent',
                  background: isCurrent
                    ? `${dim.color}12`
                    : isComplete
                    ? `${dim.color}08`
                    : '#F5F5F3',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.35rem',
                  whiteSpace: 'nowrap',
                  flexShrink: 0,
                }}
              >
                {isComplete && (
                  <CheckCircle
                    size={12}
                    color={dim.color}
                    style={{ flexShrink: 0 }}
                  />
                )}
                <span
                  style={{
                    fontFamily: "'Manrope', sans-serif",
                    fontSize: '0.72rem',
                    fontWeight: isCurrent ? 700 : 500,
                    color: isCurrent ? dim.color : '#5A5A72',
                  }}
                >
                  {dim.name}
                </span>
                <span
                  style={{
                    fontFamily: "'Manrope', sans-serif",
                    fontSize: '0.6rem',
                    color: '#8E8EA0',
                  }}
                >
                  {sectionAnswered}/5
                </span>
              </motion.button>
            );
          })}
        </div>

        {/* Current section */}
        <AnimatePresence mode="wait">
          <motion.div
            key={currentSection}
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -30 }}
            transition={{ duration: 0.3 }}
          >
            {/* Section header */}
            <div
              style={{
                background: '#FFFFFF',
                borderRadius: '16px',
                padding: '2rem',
                marginBottom: '1.5rem',
                border: `1px solid ${currentDimension.color}20`,
                boxShadow: `0 2px 16px ${currentDimension.color}08`,
              }}
            >
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.75rem',
                  marginBottom: '0.75rem',
                }}
              >
                <div
                  style={{
                    width: 12,
                    height: 12,
                    borderRadius: '50%',
                    background: currentDimension.color,
                    boxShadow: `0 0 12px ${currentDimension.color}40`,
                  }}
                />
                <h2
                  style={{
                    fontFamily: "'Cormorant Garamond', serif",
                    fontSize: '1.6rem',
                    fontWeight: 600,
                    color: '#1A1A2E',
                    margin: 0,
                  }}
                >
                  {currentDimension.name}
                </h2>
                <span
                  style={{
                    fontFamily: "'Manrope', sans-serif",
                    fontSize: '0.7rem',
                    fontWeight: 600,
                    color: '#8E8EA0',
                    background: '#F5F5F3',
                    padding: '0.2rem 0.6rem',
                    borderRadius: '12px',
                  }}
                >
                  Section {currentSection + 1} of {totalSections}
                </span>
              </div>
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  fontFamily: "'Manrope', sans-serif",
                  fontSize: '0.8rem',
                  color: '#8E8EA0',
                }}
              >
                <span>{currentDimension.lowLabel}</span>
                <span>←→</span>
                <span>{currentDimension.highLabel}</span>
              </div>
              <p
                style={{
                  fontFamily: "'Manrope', sans-serif",
                  fontSize: '0.85rem',
                  color: '#5A5A72',
                  lineHeight: 1.65,
                  marginTop: '0.75rem',
                  marginBottom: 0,
                }}
              >
                {currentDimension.description}
              </p>
            </div>

            {/* Questions */}
            {sectionQuestions.map((question, idx) => (
              <motion.div
                key={question.id}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: idx * 0.08 }}
                style={{
                  background: '#FFFFFF',
                  borderRadius: '14px',
                  padding: '1.5rem 2rem',
                  marginBottom: '1rem',
                  border:
                    answers[question.id] !== undefined
                      ? `1px solid ${currentDimension.color}30`
                      : '1px solid #E8E8EC',
                  boxShadow:
                    answers[question.id] !== undefined
                      ? `0 2px 12px ${currentDimension.color}08`
                      : '0 1px 4px rgba(0,0,0,0.02)',
                  transition: 'all 0.3s ease',
                }}
              >
                <div
                  style={{
                    display: 'flex',
                    gap: '0.75rem',
                    alignItems: 'flex-start',
                  }}
                >
                  <span
                    style={{
                      fontFamily: "'Manrope', sans-serif",
                      fontSize: '0.7rem',
                      fontWeight: 700,
                      color: currentDimension.color,
                      background: `${currentDimension.color}12`,
                      padding: '0.2rem 0.5rem',
                      borderRadius: '6px',
                      flexShrink: 0,
                      marginTop: '0.1rem',
                    }}
                  >
                    Q{currentSection * 5 + idx + 1}
                  </span>
                  <p
                    style={{
                      fontFamily: "'Manrope', sans-serif",
                      fontSize: '0.95rem',
                      color: '#1A1A2E',
                      lineHeight: 1.55,
                      margin: 0,
                    }}
                  >
                    {question.text}
                  </p>
                </div>
                <LikertScale
                  value={answers[question.id]}
                  onChange={(val) => handleAnswer(question.id, val)}
                  color={currentDimension.color}
                />
              </motion.div>
            ))}
          </motion.div>
        </AnimatePresence>

        {/* Navigation */}
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginTop: '2rem',
            gap: '1rem',
          }}
        >
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={() =>
              currentSection > 0 && setCurrentSection(currentSection - 1)
            }
            disabled={currentSection === 0}
            style={{
              fontFamily: "'Manrope', sans-serif",
              fontSize: '0.9rem',
              fontWeight: 600,
              color: currentSection === 0 ? '#D0D0D8' : '#5A5A72',
              background: 'transparent',
              border: '2px solid',
              borderColor: currentSection === 0 ? '#E8E8EC' : '#D0D0D8',
              padding: '0.7rem 1.5rem',
              borderRadius: '10px',
              cursor: currentSection === 0 ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
            }}
          >
            <ArrowLeft size={16} />
            Previous
          </motion.button>

          <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
            <AnimatePresence>
              {showSaved && (
                <motion.span
                  initial={{ opacity: 0, x: 10 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0 }}
                  style={{
                    fontFamily: "'Manrope', sans-serif",
                    fontSize: '0.75rem',
                    color: '#66BB6A',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.25rem',
                  }}
                >
                  <CheckCircle size={12} />
                  Saved
                </motion.span>
              )}
            </AnimatePresence>
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={handleSave}
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.8rem',
                fontWeight: 500,
                color: '#8E8EA0',
                background: '#F5F5F3',
                border: 'none',
                padding: '0.5rem 1rem',
                borderRadius: '8px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '0.35rem',
              }}
            >
              <Save size={12} />
              Save
            </motion.button>
          </div>

          {currentSection < totalSections - 1 ? (
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => setCurrentSection(currentSection + 1)}
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.9rem',
                fontWeight: 600,
                color: '#FFFFFF',
                background: isSectionComplete
                  ? currentDimension.color
                  : 'linear-gradient(135deg, #1A1A2E, #2D1B4E)',
                border: 'none',
                padding: '0.7rem 1.5rem',
                borderRadius: '10px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                boxShadow: '0 2px 8px rgba(0,0,0,0.15)',
              }}
            >
              Next
              <ArrowRight size={16} />
            </motion.button>
          ) : (
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={handleSubmit}
              disabled={!isAllComplete && !isSubmitting}
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.9rem',
                fontWeight: 600,
                color: '#FFFFFF',
                background:
                  isAllComplete
                    ? 'linear-gradient(135deg, #C5A059, #D4B577)'
                    : '#D0D0D8',
                border: 'none',
                padding: '0.7rem 1.5rem',
                borderRadius: '10px',
                cursor: isAllComplete ? 'pointer' : 'not-allowed',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                boxShadow: isAllComplete
                  ? '0 4px 16px rgba(197, 160, 89, 0.3)'
                  : 'none',
              }}
            >
              {isSubmitting ? (
                <>
                  <motion.div
                    animate={{ rotate: 360 }}
                    transition={{
                      duration: 1,
                      repeat: Infinity,
                      ease: 'linear',
                    }}
                    style={{
                      width: 16,
                      height: 16,
                      border: '2px solid #FFF',
                      borderTopColor: 'transparent',
                      borderRadius: '50%',
                    }}
                  />
                  Analyzing...
                </>
              ) : (
                <>
                  See Results
                  <ArrowRight size={16} />
                </>
              )}
            </motion.button>
          )}
        </div>
      </div>
    </div>
  );
};

export default FullAssessment;
