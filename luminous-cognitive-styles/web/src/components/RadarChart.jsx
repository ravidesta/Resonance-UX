import React, { useState, useRef } from 'react';
import { motion } from 'framer-motion';
import { dimensions } from '../data/dimensions';

const RadarChart = ({
  scores = {},
  adaptiveRanges = null,
  size = 400,
  showLabels = true,
  showAdaptiveRange = true,
  animated = true,
  style = {},
}) => {
  const [hoveredDim, setHoveredDim] = useState(null);
  const [tooltipPos, setTooltipPos] = useState({ x: 0, y: 0 });
  const svgRef = useRef(null);

  const center = size / 2;
  const maxRadius = size * 0.35;
  const labelRadius = size * 0.46;
  const numDimensions = dimensions.length;
  const angleStep = (2 * Math.PI) / numDimensions;
  const startAngle = -Math.PI / 2;

  const getPoint = (index, value, radius = maxRadius) => {
    const angle = startAngle + index * angleStep;
    const r = (value / 10) * radius;
    return {
      x: center + r * Math.cos(angle),
      y: center + r * Math.sin(angle),
    };
  };

  const getLabelPoint = (index) => {
    const angle = startAngle + index * angleStep;
    return {
      x: center + labelRadius * Math.cos(angle),
      y: center + labelRadius * Math.sin(angle),
    };
  };

  const getPolygonPoints = (values) => {
    return dimensions
      .map((dim, i) => {
        const val = values[dim.id] || 5;
        const pt = getPoint(i, val);
        return `${pt.x},${pt.y}`;
      })
      .join(' ');
  };

  const getAdaptiveRangePoints = (rangeType) => {
    if (!adaptiveRanges) return '';
    return dimensions
      .map((dim, i) => {
        const range = adaptiveRanges[dim.id];
        const val = range ? range[rangeType] : 5;
        const pt = getPoint(i, val);
        return `${pt.x},${pt.y}`;
      })
      .join(' ');
  };

  const gridLevels = [2, 4, 6, 8, 10];

  const handleDimHover = (index, event) => {
    const dim = dimensions[index];
    setHoveredDim(index);
    if (svgRef.current) {
      const rect = svgRef.current.getBoundingClientRect();
      setTooltipPos({
        x: event.clientX - rect.left,
        y: event.clientY - rect.top,
      });
    }
  };

  const gradientId = 'radar-fill-gradient';
  const adaptiveGradientId = 'adaptive-fill-gradient';

  return (
    <div style={{ position: 'relative', display: 'inline-block', ...style }}>
      <svg
        ref={svgRef}
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
        style={{ overflow: 'visible' }}
      >
        <defs>
          <radialGradient id={gradientId} cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#C5A059" stopOpacity="0.3" />
            <stop offset="100%" stopColor="#C5A059" stopOpacity="0.05" />
          </radialGradient>
          <radialGradient id={adaptiveGradientId} cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#C5A059" stopOpacity="0.08" />
            <stop offset="100%" stopColor="#C5A059" stopOpacity="0.02" />
          </radialGradient>
          <filter id="glow">
            <feGaussianBlur stdDeviation="3" result="coloredBlur" />
            <feMerge>
              <feMergeNode in="coloredBlur" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
          {dimensions.map((dim, i) => (
            <radialGradient
              key={dim.id}
              id={`dot-glow-${i}`}
              cx="50%"
              cy="50%"
              r="50%"
            >
              <stop offset="0%" stopColor={dim.color} stopOpacity="1" />
              <stop offset="100%" stopColor={dim.color} stopOpacity="0" />
            </radialGradient>
          ))}
        </defs>

        {/* Grid circles */}
        {gridLevels.map((level) => {
          const r = (level / 10) * maxRadius;
          return (
            <circle
              key={level}
              cx={center}
              cy={center}
              r={r}
              fill="none"
              stroke="#E8E8EC"
              strokeWidth="0.5"
              strokeDasharray={level === 10 ? 'none' : '2,4'}
              opacity="0.5"
            />
          );
        })}

        {/* Axis lines */}
        {dimensions.map((dim, i) => {
          const endPoint = getPoint(i, 10);
          return (
            <line
              key={`axis-${i}`}
              x1={center}
              y1={center}
              x2={endPoint.x}
              y2={endPoint.y}
              stroke="#E8E8EC"
              strokeWidth="0.5"
              opacity="0.5"
            />
          );
        })}

        {/* Adaptive range polygon */}
        {showAdaptiveRange && adaptiveRanges && (
          <>
            <motion.polygon
              points={getAdaptiveRangePoints('high')}
              fill={`url(#${adaptiveGradientId})`}
              stroke="#C5A059"
              strokeWidth="0.5"
              strokeDasharray="4,4"
              opacity="0.4"
              initial={animated ? { opacity: 0 } : {}}
              animate={{ opacity: 0.4 }}
              transition={{ duration: 1, delay: 0.8 }}
            />
            <motion.polygon
              points={getAdaptiveRangePoints('low')}
              fill="#FAFAF8"
              stroke="none"
              initial={animated ? { opacity: 0 } : {}}
              animate={{ opacity: 1 }}
              transition={{ duration: 1, delay: 0.8 }}
            />
          </>
        )}

        {/* Main filled area */}
        <motion.polygon
          points={getPolygonPoints(scores)}
          fill={`url(#${gradientId})`}
          stroke="#C5A059"
          strokeWidth="1.5"
          strokeLinejoin="round"
          initial={animated ? { opacity: 0, scale: 0.5 } : {}}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
          style={{ transformOrigin: `${center}px ${center}px` }}
        />

        {/* Colored edge segments */}
        {dimensions.map((dim, i) => {
          const nextI = (i + 1) % numDimensions;
          const nextDim = dimensions[nextI];
          const pt1 = getPoint(i, scores[dim.id] || 5);
          const pt2 = getPoint(nextI, scores[nextDim.id] || 5);
          return (
            <motion.line
              key={`edge-${i}`}
              x1={pt1.x}
              y1={pt1.y}
              x2={pt2.x}
              y2={pt2.y}
              stroke={dim.color}
              strokeWidth="2"
              strokeLinecap="round"
              initial={animated ? { pathLength: 0, opacity: 0 } : {}}
              animate={{ pathLength: 1, opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.3 + i * 0.1 }}
            />
          );
        })}

        {/* Data points */}
        {dimensions.map((dim, i) => {
          const val = scores[dim.id] || 5;
          const pt = getPoint(i, val);
          const isHovered = hoveredDim === i;
          return (
            <g key={`point-${i}`}>
              {/* Glow circle */}
              <motion.circle
                cx={pt.x}
                cy={pt.y}
                r={isHovered ? 16 : 10}
                fill={`url(#dot-glow-${i})`}
                opacity={isHovered ? 0.5 : 0.2}
                initial={animated ? { scale: 0 } : {}}
                animate={{ scale: 1, r: isHovered ? 16 : 10 }}
                transition={{ duration: 0.4, delay: 0.5 + i * 0.08 }}
              />
              {/* Solid dot */}
              <motion.circle
                cx={pt.x}
                cy={pt.y}
                r={isHovered ? 6 : 4}
                fill={dim.color}
                stroke="#FFFFFF"
                strokeWidth="2"
                style={{ cursor: 'pointer' }}
                initial={animated ? { scale: 0 } : {}}
                animate={{ scale: 1 }}
                transition={{
                  duration: 0.3,
                  delay: 0.5 + i * 0.08,
                  type: 'spring',
                  stiffness: 400,
                }}
                onMouseEnter={(e) => handleDimHover(i, e)}
                onMouseLeave={() => setHoveredDim(null)}
              />
            </g>
          );
        })}

        {/* Labels */}
        {showLabels &&
          dimensions.map((dim, i) => {
            const labelPt = getLabelPoint(i);
            const angle = startAngle + i * angleStep;
            const isLeft = Math.cos(angle) < -0.1;
            const isRight = Math.cos(angle) > 0.1;
            const textAnchor = isLeft ? 'end' : isRight ? 'start' : 'middle';
            const val = scores[dim.id] || 5;

            return (
              <g key={`label-${i}`}>
                <text
                  x={labelPt.x}
                  y={labelPt.y - 6}
                  textAnchor={textAnchor}
                  style={{
                    fontSize: '11px',
                    fontFamily: "'Manrope', sans-serif",
                    fontWeight: 600,
                    fill: '#1A1A2E',
                  }}
                >
                  {dim.name}
                </text>
                <text
                  x={labelPt.x}
                  y={labelPt.y + 10}
                  textAnchor={textAnchor}
                  style={{
                    fontSize: '10px',
                    fontFamily: "'Manrope', sans-serif",
                    fontWeight: 400,
                    fill: dim.color,
                  }}
                >
                  {val.toFixed(1)}
                </text>
              </g>
            );
          })}
      </svg>

      {/* Tooltip */}
      {hoveredDim !== null && (
        <motion.div
          initial={{ opacity: 0, y: 5 }}
          animate={{ opacity: 1, y: 0 }}
          style={{
            position: 'absolute',
            left: tooltipPos.x + 12,
            top: tooltipPos.y - 40,
            background: '#1A1A2E',
            color: '#FFFFFF',
            padding: '8px 14px',
            borderRadius: '8px',
            fontSize: '12px',
            fontFamily: "'Manrope', sans-serif",
            pointerEvents: 'none',
            whiteSpace: 'nowrap',
            zIndex: 10,
            boxShadow: '0 4px 16px rgba(0,0,0,0.2)',
          }}
        >
          <div style={{ fontWeight: 600, marginBottom: 2 }}>
            {dimensions[hoveredDim].name}
          </div>
          <div style={{ opacity: 0.8 }}>
            Score: {(scores[dimensions[hoveredDim].id] || 5).toFixed(1)}
          </div>
          <div style={{ opacity: 0.6, fontSize: '10px' }}>
            {dimensions[hoveredDim].lowLabel} ←→{' '}
            {dimensions[hoveredDim].highLabel}
          </div>
        </motion.div>
      )}
    </div>
  );
};

export default RadarChart;
