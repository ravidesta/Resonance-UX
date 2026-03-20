import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Dimensions, Platform } from 'react-native';
import Svg, { Polygon, Circle, Line, Text as SvgText, G, Path } from 'react-native-svg';
import { useTheme } from '../theme/ThemeContext';
import { LifewheelDimensions } from '../theme/tokens';

const AnimatedPolygon = Animated.createAnimatedComponent
  ? Animated.createAnimatedComponent(Polygon)
  : Polygon;

export default function LifewheelVisualization({
  scores = {},  // { physical: 7, emotional: 5, ... }
  size = 300,
  showLabels = true,
  animated = true,
  interactive = false,
  onDimensionPress,
}) {
  const { colors, isDark } = useTheme();
  const center = size / 2;
  const maxRadius = (size / 2) - 40;
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.8)).current;

  useEffect(() => {
    if (animated) {
      Animated.parallel([
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 1200,
          useNativeDriver: true,
        }),
        Animated.spring(scaleAnim, {
          toValue: 1,
          damping: 15,
          stiffness: 100,
          useNativeDriver: true,
        }),
      ]).start();
    } else {
      fadeAnim.setValue(1);
      scaleAnim.setValue(1);
    }
  }, []);

  const dimensions = LifewheelDimensions;
  const angleStep = (2 * Math.PI) / dimensions.length;

  // Get point on wheel for a given dimension index and score
  const getPoint = (index, score) => {
    const angle = (angleStep * index) - (Math.PI / 2); // Start from top
    const radius = (score / 10) * maxRadius;
    return {
      x: center + radius * Math.cos(angle),
      y: center + radius * Math.sin(angle),
    };
  };

  // Build the score polygon points string
  const scorePoints = dimensions.map((dim, i) => {
    const score = scores[dim.key] || 0;
    const pt = getPoint(i, score);
    return `${pt.x},${pt.y}`;
  }).join(' ');

  // Render concentric guide rings
  const rings = [2, 4, 6, 8, 10];

  // Render axis lines
  const axes = dimensions.map((_, i) => {
    const outerPt = getPoint(i, 10);
    return { x1: center, y1: center, x2: outerPt.x, y2: outerPt.y };
  });

  // Label positions
  const labelPoints = dimensions.map((dim, i) => {
    const pt = getPoint(i, 11.5);
    return { ...pt, label: dim.emoji, name: dim.label, key: dim.key };
  });

  return (
    <Animated.View
      style={[
        styles.container,
        {
          opacity: fadeAnim,
          transform: [{ scale: scaleAnim }],
        },
      ]}
    >
      <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        {/* Concentric rings */}
        {rings.map((ring) => {
          const r = (ring / 10) * maxRadius;
          return (
            <Circle
              key={ring}
              cx={center}
              cy={center}
              r={r}
              fill="none"
              stroke={isDark ? 'rgba(255,255,255,0.06)' : 'rgba(18,46,33,0.06)'}
              strokeWidth={1}
            />
          );
        })}

        {/* Axis lines */}
        {axes.map((axis, i) => (
          <Line
            key={i}
            x1={axis.x1}
            y1={axis.y1}
            x2={axis.x2}
            y2={axis.y2}
            stroke={isDark ? 'rgba(255,255,255,0.08)' : 'rgba(18,46,33,0.08)'}
            strokeWidth={1}
          />
        ))}

        {/* Score polygon fill */}
        <Polygon
          points={scorePoints}
          fill={isDark ? 'rgba(197, 160, 89, 0.15)' : 'rgba(197, 160, 89, 0.12)'}
          stroke={colors.gold}
          strokeWidth={2}
          strokeLinejoin="round"
        />

        {/* Score dots on each vertex */}
        {dimensions.map((dim, i) => {
          const score = scores[dim.key] || 0;
          const pt = getPoint(i, score);
          const dimColor = colors[dim.colorKey];
          return (
            <G key={dim.key}>
              <Circle
                cx={pt.x}
                cy={pt.y}
                r={6}
                fill={dimColor}
                stroke="#FFFFFF"
                strokeWidth={2}
              />
              {/* Glow effect */}
              <Circle
                cx={pt.x}
                cy={pt.y}
                r={12}
                fill={dimColor}
                opacity={0.2}
              />
            </G>
          );
        })}

        {/* Labels */}
        {showLabels && labelPoints.map((lp) => (
          <SvgText
            key={lp.key}
            x={lp.x}
            y={lp.y}
            fontSize={16}
            textAnchor="middle"
            alignmentBaseline="central"
          >
            {lp.label}
          </SvgText>
        ))}
      </Svg>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
});
