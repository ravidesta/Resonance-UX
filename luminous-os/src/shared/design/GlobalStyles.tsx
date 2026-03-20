import { useMemo } from 'react'

export function OrganicBlobs() {
  const blobs = useMemo(() => [
    { color: 'rgba(197, 160, 89, 0.15)', size: 500, x: '15%', y: '20%', delay: 0 },
    { color: 'rgba(92, 156, 120, 0.12)', size: 600, x: '70%', y: '60%', delay: 5 },
    { color: 'rgba(209, 224, 215, 0.18)', size: 450, x: '50%', y: '10%', delay: 10 },
    { color: 'rgba(142, 191, 164, 0.1)', size: 350, x: '85%', y: '80%', delay: 3 },
    { color: 'rgba(230, 208, 161, 0.1)', size: 400, x: '25%', y: '75%', delay: 7 },
  ], [])

  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none" style={{ zIndex: 0 }}>
      {blobs.map((blob, i) => (
        <div
          key={i}
          className="absolute rounded-full animate-breathe"
          style={{
            width: blob.size,
            height: blob.size,
            left: blob.x,
            top: blob.y,
            background: `radial-gradient(circle, ${blob.color} 0%, transparent 70%)`,
            filter: 'blur(80px)',
            animationDelay: `${blob.delay}s`,
            transform: 'translate(-50%, -50%)',
          }}
        />
      ))}
    </div>
  )
}

export function PaperNoise() {
  return <div className="paper-noise" />
}
