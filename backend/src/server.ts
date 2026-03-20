/**
 * Resonance UX Backend Server
 *
 * Node.js / Express API server with:
 * - RESTful API routes
 * - WebSocket server for real-time sync, status, and messaging
 * - JWT authentication middleware
 * - Rate limiting and security headers
 * - CORS configuration for all platform clients
 */

import express, { type Request, type Response, type NextFunction } from 'express';
import { createServer as createHttpServer } from 'http';
import { WebSocketServer, WebSocket, type RawData } from 'ws';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import jwt from 'jsonwebtoken';
import { v4 as uuid } from 'uuid';

import { apiRouter } from './routes/api';
import { SyncService } from './services/syncService';
import { NotificationService } from './services/notificationService';
import type { WSMessage, WSMessageType } from '../../shared/types';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const PORT = parseInt(process.env.PORT || '4000', 10);
const JWT_SECRET = process.env.JWT_SECRET || 'resonance-dev-secret-change-in-production';
const CORS_ORIGINS = (process.env.CORS_ORIGINS || 'http://localhost:3000,http://localhost:3001').split(',');

export interface AuthPayload {
  userId: string;
  email: string;
  iat: number;
  exp: number;
}

// Extend Express Request
declare global {
  namespace Express {
    interface Request {
      userId?: string;
      userEmail?: string;
    }
  }
}

// ---------------------------------------------------------------------------
// Express App
// ---------------------------------------------------------------------------

const app = express();

// --- Security headers ---
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
        fontSrc: ["'self'", 'https://fonts.gstatic.com'],
        imgSrc: ["'self'", 'data:', 'blob:'],
        connectSrc: ["'self'", 'wss:', 'ws:', 'https://generativelanguage.googleapis.com'],
      },
    },
    crossOriginEmbedderPolicy: false,
  }),
);

// --- CORS ---
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, curl, etc.)
      if (!origin || CORS_ORIGINS.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error(`CORS policy: origin ${origin} not allowed`));
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Device-Id', 'X-Request-Id'],
    exposedHeaders: ['X-Total-Count', 'X-Request-Id'],
    maxAge: 86400,
  }),
);

// --- Body parsing ---
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true, limit: '2mb' }));

// --- Compression ---
app.use(compression());

// --- Request ID ---
app.use((req: Request, _res: Response, next: NextFunction) => {
  req.headers['x-request-id'] = req.headers['x-request-id'] || uuid();
  next();
});

// --- Rate limiting ---
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, error: { code: 'RATE_LIMIT', message: 'Too many requests. Please slow down.' } },
});
app.use('/api', globalLimiter);

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, error: { code: 'AUTH_RATE_LIMIT', message: 'Too many auth attempts.' } },
});
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// ---------------------------------------------------------------------------
// JWT Authentication Middleware
// ---------------------------------------------------------------------------

export function authenticateToken(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null;

  if (!token) {
    res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'Authentication required.' },
    });
    return;
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET) as AuthPayload;
    req.userId = payload.userId;
    req.userEmail = payload.email;
    next();
  } catch (err) {
    const message = err instanceof jwt.TokenExpiredError ? 'Token expired.' : 'Invalid token.';
    res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message },
    });
  }
}

export function optionalAuth(req: Request, _res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null;

  if (token) {
    try {
      const payload = jwt.verify(token, JWT_SECRET) as AuthPayload;
      req.userId = payload.userId;
      req.userEmail = payload.email;
    } catch {
      // Silently ignore invalid tokens for optional auth
    }
  }

  next();
}

export function generateTokens(userId: string, email: string): { accessToken: string; refreshToken: string; expiresAt: number } {
  const expiresIn = 60 * 60; // 1 hour
  const accessToken = jwt.sign({ userId, email }, JWT_SECRET, { expiresIn });
  const refreshToken = jwt.sign({ userId, email, type: 'refresh' }, JWT_SECRET, { expiresIn: '30d' });
  return {
    accessToken,
    refreshToken,
    expiresAt: Math.floor(Date.now() / 1000) + expiresIn,
  };
}

// ---------------------------------------------------------------------------
// API Routes
// ---------------------------------------------------------------------------

app.use('/api', apiRouter);

// Health check
app.get('/health', (_req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    version: process.env.npm_package_version || '1.0.0',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use((_req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: { code: 'NOT_FOUND', message: 'Endpoint not found.' },
  });
});

// Global error handler
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error('[Resonance] Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: process.env.NODE_ENV === 'production' ? 'Internal server error.' : err.message,
    },
  });
});

// ---------------------------------------------------------------------------
// HTTP + WebSocket Server
// ---------------------------------------------------------------------------

const httpServer = createHttpServer(app);
const wss = new WebSocketServer({ server: httpServer, path: '/ws' });

// Track authenticated connections
interface AuthenticatedSocket {
  ws: WebSocket;
  userId: string;
  deviceId: string;
  subscribedStatuses: Set<string>; // userIds subscribed to
}

const connections = new Map<string, AuthenticatedSocket>(); // keyed by deviceId
const userConnections = new Map<string, Set<string>>(); // userId -> set of deviceIds

const syncService = new SyncService();
const notificationService = NotificationService.getInstance();

function broadcastToUser(userId: string, message: WSMessage, excludeDeviceId?: string): void {
  const deviceIds = userConnections.get(userId);
  if (!deviceIds) return;

  const payload = JSON.stringify(message);
  for (const deviceId of deviceIds) {
    if (deviceId === excludeDeviceId) continue;
    const conn = connections.get(deviceId);
    if (conn && conn.ws.readyState === WebSocket.OPEN) {
      conn.ws.send(payload);
    }
  }
}

function broadcastStatusToSubscribers(userId: string, message: WSMessage): void {
  for (const [, conn] of connections) {
    if (conn.subscribedStatuses.has(userId) && conn.ws.readyState === WebSocket.OPEN) {
      conn.ws.send(JSON.stringify(message));
    }
  }
}

wss.on('connection', (ws: WebSocket) => {
  let authenticated = false;
  let deviceId = '';
  let userId = '';

  // Auto-disconnect after 30s if not authenticated
  const authTimeout = setTimeout(() => {
    if (!authenticated) {
      ws.close(4001, 'Authentication timeout');
    }
  }, 30_000);

  ws.on('message', (raw: RawData) => {
    let msg: WSMessage;
    try {
      msg = JSON.parse(raw.toString());
    } catch {
      ws.send(JSON.stringify({ type: 'error', payload: { message: 'Malformed JSON' } }));
      return;
    }

    // --- Authenticate ---
    if (msg.type === 'authenticate') {
      const { token, deviceId: did } = msg.payload as { token: string; deviceId: string };
      try {
        const payload = jwt.verify(token, JWT_SECRET) as AuthPayload;
        authenticated = true;
        userId = payload.userId;
        deviceId = did;
        clearTimeout(authTimeout);

        // Register connection
        connections.set(deviceId, { ws, userId, deviceId, subscribedStatuses: new Set() });
        if (!userConnections.has(userId)) {
          userConnections.set(userId, new Set());
        }
        userConnections.get(userId)!.add(deviceId);

        ws.send(JSON.stringify({
          type: 'authenticated',
          id: uuid(),
          timestamp: new Date().toISOString(),
          payload: { userId, deviceId },
        }));
      } catch {
        ws.send(JSON.stringify({ type: 'error', payload: { message: 'Invalid token' } }));
        ws.close(4003, 'Invalid token');
      }
      return;
    }

    // All subsequent messages require authentication
    if (!authenticated) {
      ws.send(JSON.stringify({ type: 'error', payload: { message: 'Not authenticated' } }));
      return;
    }

    switch (msg.type as string) {
      case 'ping':
        ws.send(JSON.stringify({ type: 'pong', id: uuid(), timestamp: new Date().toISOString(), payload: {} }));
        break;

      case 'status-update': {
        const statusPayload = msg.payload as { status: unknown };
        broadcastStatusToSubscribers(userId, {
          type: 'status-update' as WSMessageType,
          id: uuid(),
          timestamp: new Date().toISOString(),
          payload: { userId, status: statusPayload.status },
        });
        break;
      }

      case 'status-subscribe': {
        const { targetUserId } = msg.payload as { targetUserId: string };
        const conn = connections.get(deviceId);
        if (conn) conn.subscribedStatuses.add(targetUserId);
        break;
      }

      case 'status-unsubscribe': {
        const { targetUserId } = msg.payload as { targetUserId: string };
        const conn = connections.get(deviceId);
        if (conn) conn.subscribedStatuses.delete(targetUserId);
        break;
      }

      case 'message-new': {
        const { conversationId, message: newMessage } = msg.payload as { conversationId: string; message: unknown };
        // Broadcast to all participants (simplified: broadcast to sender's other devices)
        broadcastToUser(userId, {
          type: 'message-new' as WSMessageType,
          id: uuid(),
          timestamp: new Date().toISOString(),
          payload: { conversationId, message: newMessage },
        }, deviceId);
        break;
      }

      case 'typing-start':
      case 'typing-stop': {
        const { conversationId } = msg.payload as { conversationId: string };
        broadcastToUser(userId, {
          type: msg.type as WSMessageType,
          id: uuid(),
          timestamp: new Date().toISOString(),
          payload: { conversationId, userId },
        }, deviceId);
        break;
      }

      case 'sync-push': {
        const { changes } = msg.payload as { changes: unknown[] };
        const result = syncService.processPush(userId, deviceId, changes);
        ws.send(JSON.stringify({
          type: 'sync-update',
          id: uuid(),
          timestamp: new Date().toISOString(),
          payload: result,
        }));
        break;
      }

      case 'sync-pull': {
        const { since, entityTypes, limit } = msg.payload as {
          since?: string;
          entityTypes?: string[];
          limit?: number;
          deviceId: string;
        };
        const batch = syncService.processPull(userId, deviceId, since, entityTypes, limit);
        ws.send(JSON.stringify({
          type: 'sync-update',
          id: uuid(),
          timestamp: new Date().toISOString(),
          payload: batch,
        }));
        break;
      }

      case 'call-incoming':
      case 'call-accepted':
      case 'call-declined':
      case 'call-ended':
      case 'call-signal': {
        const { targetUserId } = msg.payload as { targetUserId: string };
        broadcastToUser(targetUserId, {
          type: msg.type as WSMessageType,
          id: uuid(),
          timestamp: new Date().toISOString(),
          payload: { ...msg.payload as Record<string, unknown>, fromUserId: userId },
        });
        break;
      }

      default:
        ws.send(JSON.stringify({
          type: 'error',
          id: uuid(),
          timestamp: new Date().toISOString(),
          payload: { message: `Unknown message type: ${msg.type}` },
        }));
    }
  });

  ws.on('close', () => {
    clearTimeout(authTimeout);
    if (deviceId) {
      connections.delete(deviceId);
      const devices = userConnections.get(userId);
      if (devices) {
        devices.delete(deviceId);
        if (devices.size === 0) userConnections.delete(userId);
      }
    }
  });

  ws.on('error', (err) => {
    console.error('[WS] Connection error:', err.message);
  });
});

// Periodic cleanup of dead connections
setInterval(() => {
  for (const [deviceId, conn] of connections) {
    if (conn.ws.readyState === WebSocket.CLOSED || conn.ws.readyState === WebSocket.CLOSING) {
      connections.delete(deviceId);
      const devices = userConnections.get(conn.userId);
      if (devices) {
        devices.delete(deviceId);
        if (devices.size === 0) userConnections.delete(conn.userId);
      }
    }
  }
}, 60_000);

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------

httpServer.listen(PORT, () => {
  console.log(`[Resonance] Server listening on port ${PORT}`);
  console.log(`[Resonance] Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`[Resonance] CORS origins: ${CORS_ORIGINS.join(', ')}`);
  console.log(`[Resonance] WebSocket path: /ws`);
});

// Graceful shutdown
function shutdown(signal: string) {
  console.log(`[Resonance] ${signal} received. Shutting down gracefully...`);

  // Close all WebSocket connections
  for (const [, conn] of connections) {
    conn.ws.close(1001, 'Server shutting down');
  }
  connections.clear();
  userConnections.clear();

  wss.close(() => {
    httpServer.close(() => {
      console.log('[Resonance] Server shut down.');
      process.exit(0);
    });
  });

  // Force exit after 10s
  setTimeout(() => process.exit(1), 10_000);
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

export { app, httpServer, wss, broadcastToUser };
