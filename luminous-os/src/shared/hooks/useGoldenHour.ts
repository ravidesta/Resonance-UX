import { useState, useCallback, useRef, useEffect } from 'react'
import type { TimerPhase, TimerState } from '@/shared/types/room'

function getPhase(progress: number): TimerPhase {
  if (progress >= 1) return 'complete'
  if (progress >= 0.8) return 'golden-hour'
  if (progress >= 0.4) return 'full-day'
  return 'morning'
}

export function useGoldenHour(totalMinutes: number) {
  const totalMs = totalMinutes * 60 * 1000
  const [elapsed, setElapsed] = useState(0)
  const [isRunning, setIsRunning] = useState(false)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)
  const startTimeRef = useRef<number>(0)
  const elapsedBeforePauseRef = useRef<number>(0)

  const progress = totalMs > 0 ? Math.min(elapsed / totalMs, 1) : 0
  const phase = getPhase(progress)

  const remaining = Math.max(0, totalMs - elapsed)
  const remainingMinutes = Math.floor(remaining / 60000)
  const remainingSeconds = Math.floor((remaining % 60000) / 1000)
  const elapsedMinutes = Math.floor(elapsed / 60000)
  const elapsedSeconds = Math.floor((elapsed % 60000) / 1000)

  const tick = useCallback(() => {
    const now = Date.now()
    const newElapsed = elapsedBeforePauseRef.current + (now - startTimeRef.current)
    setElapsed(newElapsed)
    if (newElapsed >= totalMs) {
      setIsRunning(false)
      setElapsed(totalMs)
    }
  }, [totalMs])

  useEffect(() => {
    if (isRunning) {
      intervalRef.current = setInterval(tick, 250)
    }
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current)
    }
  }, [isRunning, tick])

  const start = useCallback(() => {
    startTimeRef.current = Date.now()
    elapsedBeforePauseRef.current = elapsed
    setIsRunning(true)
  }, [elapsed])

  const pause = useCallback(() => {
    elapsedBeforePauseRef.current = elapsed
    setIsRunning(false)
  }, [elapsed])

  const reset = useCallback(() => {
    setIsRunning(false)
    setElapsed(0)
    elapsedBeforePauseRef.current = 0
  }, [])

  const toggle = useCallback(() => {
    if (phase === 'complete') {
      reset()
      return
    }
    if (isRunning) pause()
    else start()
  }, [isRunning, phase, start, pause, reset])

  // CSS custom properties for ambient color shifts
  const cssVars: Record<string, string> = {
    '--gh-progress': String(progress),
    '--gh-gold-opacity': String(phase === 'golden-hour' ? Math.min((progress - 0.8) * 5, 1) * 0.4 : phase === 'complete' ? 0.4 : 0),
    '--gh-warmth': String(phase === 'golden-hour' ? Math.min((progress - 0.8) * 5, 1) : phase === 'complete' ? 1 : 0),
  }

  const state: TimerState = { phase, elapsed, total: totalMs, isRunning, progress }

  return {
    state,
    phase,
    progress,
    isRunning,
    elapsed,
    remaining,
    elapsedMinutes,
    elapsedSeconds,
    remainingMinutes,
    remainingSeconds,
    start,
    pause,
    reset,
    toggle,
    cssVars,
  }
}
