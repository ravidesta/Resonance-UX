import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { useLocation, useNavigate } from 'react-router-dom';
import {
  Share2,
  Download,
  ArrowRight,
  Target,
  TrendingUp,
  Compass,
  Printer,
} from 'lucide-react';
import { dimensions } from '../data/dimensions';
import { getInterpretation } from '../data/interpretations';
import {
  generateFullProfile,
  loadProfile,
  getDistinctiveDimensions,
  computeAdaptiveRange,
} from '../utils/scoring';
import RadarChart from './RadarChart';

const CognitiveSignature = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [profile, setProfile] = useState(null);
  const [expandedDim, setExpandedDim] = useState(null);
  const [showShareTooltip, setShowShareTooltip] = useState(false);

  useEffect(() => {
    const stateProfile = location.state?.profile;
    if (stateProfile) {
      setProfile(stateProfile);
    } else {
      const saved = loadProfile();
      if (saved) {
        setProfile(saved);
      }
    }
  }, [location.state]);

  if (!profile) {
    return (
      <div
        style={{
          minHeight: '100vh',
          background: '#FAFAF8',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          paddingTop: '5rem',
        }}
      >
        <div style={{ textAlign: 'center' }}>
          <h2
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '2rem',
              fontWeight: 300,
              color: '#1A1A2E',
              marginBottom: '1rem',
            }}
          >
            No Profile Found
          </h2>
          <p
            style={{
              fontFamily: "'Manrope', sans-serif",
              color: '#5A5A72',
              marginBottom: '2rem',
            }}
          >
            Take an assessment to discover your cognitive style.
          </p>
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => navigate('/quick-profile')}
            style={{
              fontFamily: "'Manrope', sans-serif",
              fontSize: '1rem',
              fontWeight: 600,
              color: '#FFFFFF',
              background: 'linear-gradient(135deg, #1A1A2E, #2D1B4E)',
              border: 'none',
              padding: '1rem 2rem',
              borderRadius: '12px',
              cursor: 'pointer',
            }}
          >
            Take Quick Profile
          </motion.button>
        </div>
      </div>
    );
  }

  const { scores, adaptiveRanges, profileType, assessmentType } = profile;
  const distinctiveDims = getDistinctiveDimensions(scores, 3);

  const handleShare = async () => {
    const text = `My Luminous Cognitive Style: "${profileType}"\n\n${dimensions
      .map(
        (d) =>
          `${d.name}: ${(scores[d.id] || 5).toFixed(1)} (${d.lowLabel} - ${d.highLabel})`
      )
      .join('\n')}\n\nDiscover yours at luminouscognitivestyles.com`;

    if (navigator.share) {
      try {
        await navigator.share({ title: 'My Cognitive Style', text });
      } catch {
        /* user cancelled */
      }
    } else {
      await navigator.clipboard.writeText(text);
      setShowShareTooltip(true);
      setTimeout(() => setShowShareTooltip(false), 2000);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        background: '#FAFAF8',
        paddingTop: '6rem',
        paddingBottom: '4rem',
      }}
    >
      <div style={{ maxWidth: '900px', margin: '0 auto', padding: '0 1.5rem' }}>
        {/* Hero section */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          style={{
            textAlign: 'center',
            marginBottom: '3rem',
          }}
        >
          <motion.div
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
            style={{
              display: 'inline-block',
              background:
                'linear-gradient(135deg, #C5A05920, #C5A05908)',
              padding: '0.4rem 1.2rem',
              borderRadius: '20px',
              marginBottom: '1rem',
            }}
          >
            <span
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.7rem',
                fontWeight: 700,
                color: '#C5A059',
                textTransform: 'uppercase',
                letterSpacing: '0.15em',
              }}
            >
              Your Cognitive Signature
            </span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '3.5rem',
              fontWeight: 300,
              color: '#1A1A2E',
              lineHeight: 1.1,
              marginBottom: '0.5rem',
            }}
          >
            {profileType}
          </motion.h1>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
            style={{
              fontFamily: "'Manrope', sans-serif",
              fontSize: '0.85rem',
              color: '#8E8EA0',
            }}
          >
            Based on your{' '}
            {assessmentType === 'full'
              ? 'Dimensional Self-Report'
              : 'Quick Profile'}{' '}
            assessment
          </motion.p>

          {/* Action buttons */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.6 }}
            style={{
              display: 'flex',
              justifyContent: 'center',
              gap: '0.75rem',
              marginTop: '1.5rem',
              position: 'relative',
            }}
          >
            <motion.button
              whileHover={{ scale: 1.03 }}
              whileTap={{ scale: 0.97 }}
              onClick={handleShare}
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.8rem',
                fontWeight: 600,
                color: '#5A5A72',
                background: '#FFFFFF',
                border: '1px solid #E8E8EC',
                padding: '0.5rem 1.2rem',
                borderRadius: '8px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '0.4rem',
              }}
            >
              <Share2 size={14} />
              Share
            </motion.button>
            {showShareTooltip && (
              <motion.div
                initial={{ opacity: 0, y: 5 }}
                animate={{ opacity: 1, y: 0 }}
                style={{
                  position: 'absolute',
                  top: '100%',
                  marginTop: '0.5rem',
                  background: '#1A1A2E',
                  color: '#FFF',
                  padding: '0.4rem 0.8rem',
                  borderRadius: '6px',
                  fontSize: '0.7rem',
                  fontFamily: "'Manrope', sans-serif",
                }}
              >
                Copied to clipboard
              </motion.div>
            )}
            <motion.button
              whileHover={{ scale: 1.03 }}
              whileTap={{ scale: 0.97 }}
              onClick={handlePrint}
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.8rem',
                fontWeight: 600,
                color: '#5A5A72',
                background: '#FFFFFF',
                border: '1px solid #E8E8EC',
                padding: '0.5rem 1.2rem',
                borderRadius: '8px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '0.4rem',
              }}
            >
              <Printer size={14} />
              Print
            </motion.button>
          </motion.div>
        </motion.div>

        {/* Radar chart */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.4, duration: 0.6 }}
          style={{
            display: 'flex',
            justifyContent: 'center',
            marginBottom: '3rem',
            background: '#FFFFFF',
            borderRadius: '20px',
            padding: '2rem',
            boxShadow: '0 2px 16px rgba(26, 26, 46, 0.06)',
          }}
        >
          <RadarChart
            scores={scores}
            adaptiveRanges={adaptiveRanges}
            size={420}
            animated={true}
          />
        </motion.div>

        {/* Distinctive dimensions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7 }}
          style={{ marginBottom: '3rem' }}
        >
          <h2
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '1.6rem',
              fontWeight: 500,
              color: '#1A1A2E',
              marginBottom: '1rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
            }}
          >
            <Target size={20} color="#C5A059" />
            Your Most Distinctive Dimensions
          </h2>
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
              gap: '1rem',
            }}
          >
            {distinctiveDims.map((dim, idx) => (
              <motion.div
                key={dim.dimensionId}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.8 + idx * 0.1 }}
                style={{
                  background: '#FFFFFF',
                  borderRadius: '14px',
                  padding: '1.5rem',
                  border: `1px solid ${dim.color}25`,
                  boxShadow: `0 2px 12px ${dim.color}10`,
                }}
              >
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                    marginBottom: '0.5rem',
                  }}
                >
                  <div
                    style={{
                      width: 10,
                      height: 10,
                      borderRadius: '50%',
                      background: dim.color,
                    }}
                  />
                  <span
                    style={{
                      fontFamily: "'Manrope', sans-serif",
                      fontSize: '0.85rem',
                      fontWeight: 700,
                      color: '#1A1A2E',
                    }}
                  >
                    {dim.name}
                  </span>
                </div>
                <div
                  style={{
                    fontFamily: "'Cormorant Garamond', serif",
                    fontSize: '2rem',
                    fontWeight: 600,
                    color: dim.color,
                  }}
                >
                  {dim.score.toFixed(1)}
                </div>
                <div
                  style={{
                    fontFamily: "'Manrope', sans-serif",
                    fontSize: '0.8rem',
                    fontWeight: 600,
                    color: dim.color,
                    marginTop: '0.25rem',
                  }}
                >
                  {dim.label}
                </div>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* All dimensions detail */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
        >
          <h2
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '1.6rem',
              fontWeight: 500,
              color: '#1A1A2E',
              marginBottom: '1.5rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
            }}
          >
            <Compass size={20} color="#C5A059" />
            Your Seven Dimensions
          </h2>

          {dimensions.map((dim, idx) => {
            const score = scores[dim.id] || 5;
            const range = adaptiveRanges?.[dim.id] || computeAdaptiveRange(score);
            const interp = getInterpretation(dim.id, score);
            const isExpanded = expandedDim === dim.id;

            return (
              <motion.div
                key={dim.id}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 1.1 + idx * 0.08 }}
                style={{
                  background: '#FFFFFF',
                  borderRadius: '16px',
                  marginBottom: '1rem',
                  overflow: 'hidden',
                  border: isExpanded
                    ? `1px solid ${dim.color}30`
                    : '1px solid #E8E8EC',
                  boxShadow: isExpanded
                    ? `0 4px 20px ${dim.color}12`
                    : '0 1px 4px rgba(0,0,0,0.02)',
                  transition: 'all 0.3s ease',
                }}
              >
                {/* Dimension header - clickable */}
                <div
                  onClick={() =>
                    setExpandedDim(isExpanded ? null : dim.id)
                  }
                  style={{
                    padding: '1.25rem 1.5rem',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                  }}
                >
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.75rem',
                    }}
                  >
                    <div
                      style={{
                        width: 10,
                        height: 10,
                        borderRadius: '50%',
                        background: dim.color,
                        boxShadow: `0 0 8px ${dim.color}40`,
                      }}
                    />
                    <span
                      style={{
                        fontFamily: "'Cormorant Garamond', serif",
                        fontSize: '1.2rem',
                        fontWeight: 600,
                        color: '#1A1A2E',
                      }}
                    >
                      {dim.name}
                    </span>
                  </div>

                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '1rem',
                    }}
                  >
                    {/* Mini score bar */}
                    <div
                      style={{
                        width: '120px',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '0.5rem',
                      }}
                    >
                      <span
                        style={{
                          fontFamily: "'Manrope', sans-serif",
                          fontSize: '0.6rem',
                          color: '#8E8EA0',
                          width: '20px',
                          textAlign: 'right',
                        }}
                      >
                        {dim.lowLabel.substring(0, 3)}
                      </span>
                      <div
                        style={{
                          flex: 1,
                          height: '4px',
                          background: '#E8E8EC',
                          borderRadius: '2px',
                          position: 'relative',
                        }}
                      >
                        {/* Adaptive range */}
                        <div
                          style={{
                            position: 'absolute',
                            left: `${((range.low - 1) / 9) * 100}%`,
                            width: `${((range.high - range.low) / 9) * 100}%`,
                            height: '100%',
                            background: `${dim.color}25`,
                            borderRadius: '2px',
                          }}
                        />
                        {/* Score dot */}
                        <div
                          style={{
                            position: 'absolute',
                            left: `${((score - 1) / 9) * 100}%`,
                            top: '50%',
                            transform: 'translate(-50%, -50%)',
                            width: '8px',
                            height: '8px',
                            borderRadius: '50%',
                            background: dim.color,
                            boxShadow: `0 0 6px ${dim.color}50`,
                          }}
                        />
                      </div>
                      <span
                        style={{
                          fontFamily: "'Manrope', sans-serif",
                          fontSize: '0.6rem',
                          color: '#8E8EA0',
                          width: '20px',
                        }}
                      >
                        {dim.highLabel.substring(0, 3)}
                      </span>
                    </div>

                    <span
                      style={{
                        fontFamily: "'Manrope', sans-serif",
                        fontSize: '1rem',
                        fontWeight: 700,
                        color: dim.color,
                        minWidth: '2.5rem',
                        textAlign: 'right',
                      }}
                    >
                      {score.toFixed(1)}
                    </span>

                    <motion.span
                      animate={{ rotate: isExpanded ? 90 : 0 }}
                      style={{
                        color: '#8E8EA0',
                        fontSize: '1.2rem',
                        lineHeight: 1,
                      }}
                    >
                      ›
                    </motion.span>
                  </div>
                </div>

                {/* Expanded content */}
                {isExpanded && interp && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: 'auto', opacity: 1 }}
                    transition={{ duration: 0.3 }}
                    style={{
                      padding: '0 1.5rem 1.5rem',
                      borderTop: `1px solid ${dim.color}15`,
                    }}
                  >
                    <div style={{ paddingTop: '1rem' }}>
                      {/* Range label */}
                      <div
                        style={{
                          display: 'inline-block',
                          background: `${dim.color}12`,
                          padding: '0.25rem 0.75rem',
                          borderRadius: '12px',
                          marginBottom: '1rem',
                        }}
                      >
                        <span
                          style={{
                            fontFamily: "'Manrope', sans-serif",
                            fontSize: '0.75rem',
                            fontWeight: 600,
                            color: dim.color,
                          }}
                        >
                          {interp.range}
                        </span>
                      </div>

                      {/* Home Territory */}
                      <div style={{ marginBottom: '1.25rem' }}>
                        <h4
                          style={{
                            fontFamily: "'Manrope', sans-serif",
                            fontSize: '0.8rem',
                            fontWeight: 700,
                            color: '#1A1A2E',
                            marginBottom: '0.4rem',
                            textTransform: 'uppercase',
                            letterSpacing: '0.05em',
                          }}
                        >
                          Home Territory
                        </h4>
                        <p
                          style={{
                            fontFamily: "'Manrope', sans-serif",
                            fontSize: '0.88rem',
                            color: '#5A5A72',
                            lineHeight: 1.7,
                            margin: 0,
                          }}
                        >
                          {interp.homeTerritory}
                        </p>
                      </div>

                      {/* Adaptive Range */}
                      <div style={{ marginBottom: '1.25rem' }}>
                        <h4
                          style={{
                            fontFamily: "'Manrope', sans-serif",
                            fontSize: '0.8rem',
                            fontWeight: 700,
                            color: '#1A1A2E',
                            marginBottom: '0.4rem',
                            textTransform: 'uppercase',
                            letterSpacing: '0.05em',
                          }}
                        >
                          Adaptive Range
                        </h4>
                        <p
                          style={{
                            fontFamily: "'Manrope', sans-serif",
                            fontSize: '0.85rem',
                            color: '#5A5A72',
                            margin: 0,
                          }}
                        >
                          You can comfortably operate between{' '}
                          <strong style={{ color: dim.color }}>
                            {range.low.toFixed(1)}
                          </strong>{' '}
                          and{' '}
                          <strong style={{ color: dim.color }}>
                            {range.high.toFixed(1)}
                          </strong>{' '}
                          on this dimension.
                        </p>
                      </div>

                      {/* Strengths */}
                      <div style={{ marginBottom: '1.25rem' }}>
                        <h4
                          style={{
                            fontFamily: "'Manrope', sans-serif",
                            fontSize: '0.8rem',
                            fontWeight: 700,
                            color: '#1A1A2E',
                            marginBottom: '0.4rem',
                            textTransform: 'uppercase',
                            letterSpacing: '0.05em',
                          }}
                        >
                          Strengths
                        </h4>
                        <ul
                          style={{
                            margin: 0,
                            paddingLeft: '1.25rem',
                          }}
                        >
                          {interp.strengths.map((s, i) => (
                            <li
                              key={i}
                              style={{
                                fontFamily: "'Manrope', sans-serif",
                                fontSize: '0.85rem',
                                color: '#5A5A72',
                                lineHeight: 1.7,
                              }}
                            >
                              {s}
                            </li>
                          ))}
                        </ul>
                      </div>

                      {/* Growth Edges */}
                      <div style={{ marginBottom: '1.25rem' }}>
                        <h4
                          style={{
                            fontFamily: "'Manrope', sans-serif",
                            fontSize: '0.8rem',
                            fontWeight: 700,
                            color: '#1A1A2E',
                            marginBottom: '0.4rem',
                            textTransform: 'uppercase',
                            letterSpacing: '0.05em',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '0.4rem',
                          }}
                        >
                          <TrendingUp size={14} />
                          Growth Edges
                        </h4>
                        <ul
                          style={{
                            margin: 0,
                            paddingLeft: '1.25rem',
                          }}
                        >
                          {interp.growthEdges.map((g, i) => (
                            <li
                              key={i}
                              style={{
                                fontFamily: "'Manrope', sans-serif",
                                fontSize: '0.85rem',
                                color: '#5A5A72',
                                lineHeight: 1.7,
                              }}
                            >
                              {g}
                            </li>
                          ))}
                        </ul>
                      </div>

                      {/* Famous Examples */}
                      <div>
                        <h4
                          style={{
                            fontFamily: "'Manrope', sans-serif",
                            fontSize: '0.8rem',
                            fontWeight: 700,
                            color: '#1A1A2E',
                            marginBottom: '0.4rem',
                            textTransform: 'uppercase',
                            letterSpacing: '0.05em',
                          }}
                        >
                          Notable Examples
                        </h4>
                        <div
                          style={{
                            display: 'flex',
                            flexWrap: 'wrap',
                            gap: '0.5rem',
                          }}
                        >
                          {interp.famousExamples.map((ex, i) => (
                            <span
                              key={i}
                              style={{
                                fontFamily: "'Manrope', sans-serif",
                                fontSize: '0.78rem',
                                color: '#5A5A72',
                                background: '#F5F5F3',
                                padding: '0.3rem 0.7rem',
                                borderRadius: '8px',
                              }}
                            >
                              {ex}
                            </span>
                          ))}
                        </div>
                      </div>
                    </div>
                  </motion.div>
                )}
              </motion.div>
            );
          })}
        </motion.div>

        {/* CTA for full assessment */}
        {assessmentType === 'quick' && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.5 }}
            style={{
              background:
                'linear-gradient(135deg, #1A1A2E, #2D1B4E)',
              borderRadius: '20px',
              padding: '2.5rem',
              textAlign: 'center',
              marginTop: '3rem',
            }}
          >
            <h3
              style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: '1.8rem',
                fontWeight: 400,
                color: '#FFFFFF',
                marginBottom: '0.75rem',
              }}
            >
              Want deeper insights?
            </h3>
            <p
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.9rem',
                color: '#B0B0C0',
                marginBottom: '1.5rem',
                maxWidth: '480px',
                margin: '0 auto 1.5rem',
                lineHeight: 1.6,
              }}
            >
              The full 35-question Dimensional Self-Report provides a more
              nuanced picture of your cognitive style with validated
              psychometric precision.
            </p>
            <motion.button
              whileHover={{ scale: 1.03 }}
              whileTap={{ scale: 0.97 }}
              onClick={() => navigate('/assessment')}
              style={{
                fontFamily: "'Manrope', sans-serif",
                fontSize: '0.95rem',
                fontWeight: 600,
                color: '#1A1A2E',
                background:
                  'linear-gradient(135deg, #C5A059, #D4B577)',
                border: 'none',
                padding: '0.85rem 2rem',
                borderRadius: '10px',
                cursor: 'pointer',
                display: 'inline-flex',
                alignItems: 'center',
                gap: '0.5rem',
                boxShadow: '0 4px 20px rgba(197, 160, 89, 0.3)',
              }}
            >
              Take Full Assessment
              <ArrowRight size={16} />
            </motion.button>
          </motion.div>
        )}
      </div>
    </div>
  );
};

export default CognitiveSignature;
