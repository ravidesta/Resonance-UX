import React, { useState, useRef, useCallback } from 'react';
import { motion } from 'framer-motion';

const DimensionSlider = ({
  dimension,
  value = 5,
  onChange,
  showDescription = true,
  style = {},
}) => {
  const [isDragging, setIsDragging] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const trackRef = useRef(null);

  const handleInteraction = useCallback(
    (clientX) => {
      if (!trackRef.current) return;
      const rect = trackRef.current.getBoundingClientRect();
      const ratio = Math.max(0, Math.min(1, (clientX - rect.left) / rect.width));
      const newValue = Math.round(ratio * 9 + 1);
      onChange(newValue);
    },
    [onChange]
  );

  const handleMouseDown = (e) => {
    setIsDragging(true);
    handleInteraction(e.clientX);
    const handleMouseMove = (e) => handleInteraction(e.clientX);
    const handleMouseUp = () => {
      setIsDragging(false);
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseup', handleMouseUp);
  };

  const handleTouchStart = (e) => {
    setIsDragging(true);
    handleInteraction(e.touches[0].clientX);
    const handleTouchMove = (e) => {
      e.preventDefault();
      handleInteraction(e.touches[0].clientX);
    };
    const handleTouchEnd = () => {
      setIsDragging(false);
      window.removeEventListener('touchmove', handleTouchMove);
      window.removeEventListener('touchend', handleTouchEnd);
    };
    window.addEventListener('touchmove', handleTouchMove, { passive: false });
    window.addEventListener('touchend', handleTouchEnd);
  };

  const percentage = ((value - 1) / 9) * 100;
  const { color, name, lowLabel, highLabel, description } = dimension;

  const tickMarks = Array.from({ length: 10 }, (_, i) => i + 1);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      style={{
        marginBottom: '2rem',
        ...style,
      }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Header */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '0.75rem',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <div
            style={{
              width: 8,
              height: 8,
              borderRadius: '50%',
              background: color,
              boxShadow: `0 0 8px ${color}60`,
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
            {name}
          </span>
        </div>
        <motion.span
          key={value}
          initial={{ scale: 1.3, color: color }}
          animate={{ scale: 1, color: '#1A1A2E' }}
          style={{
            fontFamily: "'Manrope', sans-serif",
            fontSize: '1.1rem',
            fontWeight: 700,
            minWidth: '2rem',
            textAlign: 'right',
          }}
        >
          {value}
        </motion.span>
      </div>

      {/* Labels row */}
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
            fontWeight: 500,
            color: value <= 4 ? color : '#8E8EA0',
            textTransform: 'uppercase',
            letterSpacing: '0.05em',
            transition: 'color 0.3s ease',
          }}
        >
          {lowLabel}
        </span>
        <span
          style={{
            fontFamily: "'Manrope', sans-serif",
            fontSize: '0.75rem',
            fontWeight: 500,
            color: value >= 7 ? color : '#8E8EA0',
            textTransform: 'uppercase',
            letterSpacing: '0.05em',
            transition: 'color 0.3s ease',
          }}
        >
          {highLabel}
        </span>
      </div>

      {/* Slider track */}
      <div
        ref={trackRef}
        onMouseDown={handleMouseDown}
        onTouchStart={handleTouchStart}
        style={{
          position: 'relative',
          height: '40px',
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          userSelect: 'none',
          touchAction: 'none',
        }}
      >
        {/* Background track */}
        <div
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            height: '6px',
            borderRadius: '3px',
            background: '#E8E8EC',
            top: '50%',
            transform: 'translateY(-50%)',
          }}
        />

        {/* Filled track */}
        <motion.div
          style={{
            position: 'absolute',
            left: 0,
            height: '6px',
            borderRadius: '3px',
            background: `linear-gradient(90deg, ${color}40, ${color})`,
            top: '50%',
            transform: 'translateY(-50%)',
          }}
          animate={{ width: `${percentage}%` }}
          transition={{ duration: 0.2, ease: 'easeOut' }}
        />

        {/* Tick marks */}
        {tickMarks.map((tick) => {
          const tickPercent = ((tick - 1) / 9) * 100;
          return (
            <div
              key={tick}
              style={{
                position: 'absolute',
                left: `${tickPercent}%`,
                top: '50%',
                transform: 'translate(-50%, -50%)',
                width: tick === value ? 0 : 2,
                height: tick === value ? 0 : 6,
                borderRadius: '1px',
                background: tick <= value ? `${color}60` : '#D0D0D8',
                transition: 'all 0.2s ease',
              }}
            />
          );
        })}

        {/* Thumb */}
        <motion.div
          animate={{
            left: `${percentage}%`,
            scale: isDragging ? 1.2 : isHovered ? 1.05 : 1,
          }}
          transition={{
            left: { duration: 0.2, ease: 'easeOut' },
            scale: { duration: 0.15 },
          }}
          style={{
            position: 'absolute',
            top: '50%',
            transform: 'translate(-50%, -50%)',
            width: '24px',
            height: '24px',
            borderRadius: '50%',
            background: '#FFFFFF',
            border: `3px solid ${color}`,
            boxShadow: isDragging
              ? `0 0 0 6px ${color}20, 0 2px 8px rgba(0,0,0,0.15)`
              : `0 2px 6px rgba(0,0,0,0.1)`,
            transition: 'box-shadow 0.2s ease',
            zIndex: 2,
          }}
        >
          {/* Inner glow dot */}
          <motion.div
            animate={{
              opacity: isDragging ? 1 : 0.6,
              scale: isDragging ? 1.2 : 1,
            }}
            style={{
              width: '8px',
              height: '8px',
              borderRadius: '50%',
              background: color,
              position: 'absolute',
              top: '50%',
              left: '50%',
              transform: 'translate(-50%, -50%)',
            }}
          />
        </motion.div>
      </div>

      {/* Description */}
      {showDescription && (
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: isHovered ? 1 : 0.6 }}
          style={{
            fontFamily: "'Manrope', sans-serif",
            fontSize: '0.8rem',
            lineHeight: 1.6,
            color: '#5A5A72',
            marginTop: '0.5rem',
            transition: 'opacity 0.3s ease',
          }}
        >
          {description}
        </motion.p>
      )}
    </motion.div>
  );
};

export default DimensionSlider;
