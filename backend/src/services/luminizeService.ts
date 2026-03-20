/**
 * Resonance UX Luminize AI Service
 *
 * AI integration for:
 * - Prose refinement (via Gemini API)
 * - Psychological biomarker translation (clinical -> human-readable)
 * - Empathetic response drafting
 * - Per-user rate limiting
 * - Response caching for efficiency
 */

import type { LuminizeRequest, LuminizeResponse, LuminizeChange } from '../../../shared/types';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
const MAX_REQUESTS_PER_HOUR = parseInt(process.env.LUMINIZE_RATE_LIMIT || '60', 10);
const CACHE_TTL_MS = 10 * 60 * 1000; // 10 minutes

// ---------------------------------------------------------------------------
// Rate Limiter
// ---------------------------------------------------------------------------

interface RateLimitEntry {
  count: number;
  windowStart: number;
}

class PerUserRateLimiter {
  private limits: Map<string, RateLimitEntry> = new Map();
  private readonly maxRequests: number;
  private readonly windowMs: number;

  constructor(maxRequests: number, windowMs: number = 60 * 60 * 1000) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
  }

  check(userId: string): { allowed: boolean; remaining: number; resetAt: number } {
    const now = Date.now();
    const entry = this.limits.get(userId);

    if (!entry || now - entry.windowStart > this.windowMs) {
      this.limits.set(userId, { count: 1, windowStart: now });
      return { allowed: true, remaining: this.maxRequests - 1, resetAt: now + this.windowMs };
    }

    if (entry.count >= this.maxRequests) {
      return {
        allowed: false,
        remaining: 0,
        resetAt: entry.windowStart + this.windowMs,
      };
    }

    entry.count++;
    return {
      allowed: true,
      remaining: this.maxRequests - entry.count,
      resetAt: entry.windowStart + this.windowMs,
    };
  }

  reset(userId: string): void {
    this.limits.delete(userId);
  }

  /** Periodic cleanup of expired entries */
  cleanup(): void {
    const now = Date.now();
    for (const [userId, entry] of this.limits) {
      if (now - entry.windowStart > this.windowMs) {
        this.limits.delete(userId);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Response Cache
// ---------------------------------------------------------------------------

interface CacheEntry<T> {
  value: T;
  expiresAt: number;
}

class ResponseCache<T> {
  private cache: Map<string, CacheEntry<T>> = new Map();

  get(key: string): T | null {
    const entry = this.cache.get(key);
    if (!entry) return null;
    if (Date.now() > entry.expiresAt) {
      this.cache.delete(key);
      return null;
    }
    return entry.value;
  }

  set(key: string, value: T, ttlMs: number): void {
    this.cache.set(key, { value, expiresAt: Date.now() + ttlMs });
  }

  generateKey(...parts: string[]): string {
    // Simple hash: join parts and create a basic hash
    const str = parts.join('|');
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash |= 0;
    }
    return `lum_${Math.abs(hash).toString(36)}`;
  }

  cleanup(): void {
    const now = Date.now();
    for (const [key, entry] of this.cache) {
      if (now > entry.expiresAt) {
        this.cache.delete(key);
      }
    }
  }

  get size(): number {
    return this.cache.size;
  }
}

// ---------------------------------------------------------------------------
// Gemini API Client
// ---------------------------------------------------------------------------

interface GeminiRequest {
  contents: Array<{
    role: string;
    parts: Array<{ text: string }>;
  }>;
  generationConfig?: {
    temperature?: number;
    topP?: number;
    maxOutputTokens?: number;
  };
  systemInstruction?: {
    parts: Array<{ text: string }>;
  };
}

interface GeminiResponse {
  candidates?: Array<{
    content: {
      parts: Array<{ text: string }>;
    };
  }>;
  error?: { message: string; code: number };
}

async function callGemini(request: GeminiRequest): Promise<string> {
  if (!GEMINI_API_KEY) {
    throw new Error('GEMINI_API_KEY is not configured. Set it in environment variables.');
  }

  const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(request),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Gemini API error (${response.status}): ${errorText}`);
  }

  const data = (await response.json()) as GeminiResponse;

  if (data.error) {
    throw new Error(`Gemini API error: ${data.error.message}`);
  }

  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) {
    throw new Error('No response generated from Gemini API.');
  }

  return text;
}

// ---------------------------------------------------------------------------
// Prompt Templates
// ---------------------------------------------------------------------------

const SYSTEM_PROMPT = `You are Luminize, the AI writing assistant for Resonance — a philosophy-driven platform for calm, intentional digital experiences. Your role is to refine prose while preserving the author's unique voice. You value clarity, warmth, spaciousness, and precision. Avoid jargon, corporate language, or filler. Every word should earn its place.`;

function buildRefinePrompt(req: LuminizeRequest): string {
  const styleInstructions: Record<string, string> = {
    refine: 'Gently improve clarity, rhythm, and word choice. Preserve the author\'s voice and intent. Make it feel more considered, not more formal.',
    simplify: 'Simplify without dumbing down. Remove unnecessary complexity. Make every sentence clear and accessible. Maintain warmth.',
    expand: 'Thoughtfully expand the ideas. Add nuance, examples, or sensory detail where it serves the message. Do not pad with filler.',
    empathize: 'Adjust the tone to be warmer, more empathetic, and more human. The reader should feel seen and respected.',
    formalize: 'Make the tone more professional and polished while keeping it genuine. Avoid sounding corporate or impersonal.',
  };

  const instruction = styleInstructions[req.style] || styleInstructions.refine;

  let prompt = `## Task\n${instruction}\n\n`;
  if (req.preserveVoice) {
    prompt += `## Important\nPreserve the author's unique voice and personality. This is their writing, not yours.\n\n`;
  }
  if (req.context) {
    prompt += `## Context\n${req.context}\n\n`;
  }
  prompt += `## Original Text\n${req.text}\n\n`;
  prompt += `## Response Format\nReturn a JSON object with:\n- "refined": the improved text\n- "changes": array of { "type": "word"|"phrase"|"sentence"|"structure", "original": "...", "replacement": "...", "reason": "..." }\n- "confidence": number 0-1 indicating how confident you are the refinement improves the text\n\nReturn ONLY valid JSON, no markdown fences.`;

  return prompt;
}

function buildBiomarkerPrompt(req: {
  biomarkerName: string;
  value: number;
  unit: string;
  referenceRange?: { min?: number; max?: number };
}): string {
  let prompt = `## Task\nTranslate this biomarker result into clear, empathetic, non-alarmist language that a patient can understand. Use a warm, reassuring tone. Explain what the biomarker measures, what this specific value means, and any gentle suggestions.\n\n`;
  prompt += `## Biomarker\n- Name: ${req.biomarkerName}\n- Value: ${req.value} ${req.unit}\n`;
  if (req.referenceRange) {
    if (req.referenceRange.min !== undefined) prompt += `- Reference Min: ${req.referenceRange.min} ${req.unit}\n`;
    if (req.referenceRange.max !== undefined) prompt += `- Reference Max: ${req.referenceRange.max} ${req.unit}\n`;
  }
  prompt += `\n## Response Format\nReturn a JSON object with:\n- "summary": one-sentence plain-language summary\n- "explanation": 2-3 sentences explaining what this means\n- "status": "optimal" | "normal" | "attention" | "concern"\n- "suggestion": a gentle, non-prescriptive suggestion (or null if within range)\n\nReturn ONLY valid JSON, no markdown fences.`;

  return prompt;
}

function buildEmpathyPrompt(req: {
  incomingMessage: string;
  relationship: string;
  tone: string;
}): string {
  return `## Task\nDraft a thoughtful, empathetic response to this message. The relationship is: ${req.relationship}. The desired tone is: ${req.tone}. The response should feel genuine, not performative. It should acknowledge the sender's feelings and communicate care.\n\n## Incoming Message\n${req.incomingMessage}\n\n## Response Format\nReturn a JSON object with:\n- "response": the drafted reply\n- "alternates": array of 2 shorter/different-tone alternatives\n- "emotionalRead": brief description of the emotional content detected in the incoming message\n\nReturn ONLY valid JSON, no markdown fences.`;
}

// ---------------------------------------------------------------------------
// Luminize Service
// ---------------------------------------------------------------------------

export class LuminizeService {
  private rateLimiter: PerUserRateLimiter;
  private cache: ResponseCache<unknown>;
  private cleanupInterval: ReturnType<typeof setInterval>;

  constructor() {
    this.rateLimiter = new PerUserRateLimiter(MAX_REQUESTS_PER_HOUR);
    this.cache = new ResponseCache();

    // Periodic cleanup every 5 minutes
    this.cleanupInterval = setInterval(() => {
      this.rateLimiter.cleanup();
      this.cache.cleanup();
    }, 5 * 60 * 1000);
  }

  destroy(): void {
    clearInterval(this.cleanupInterval);
  }

  private checkRateLimit(userId: string): void {
    const result = this.rateLimiter.check(userId);
    if (!result.allowed) {
      const resetIn = Math.ceil((result.resetAt - Date.now()) / 60000);
      throw new Error(
        `Rate limit exceeded. You can make ${MAX_REQUESTS_PER_HOUR} Luminize requests per hour. ` +
        `Try again in ${resetIn} minute${resetIn > 1 ? 's' : ''}.`,
      );
    }
  }

  // ---- Prose Refinement ----

  async refineProse(userId: string, req: LuminizeRequest): Promise<LuminizeResponse> {
    this.checkRateLimit(userId);

    // Check cache
    const cacheKey = this.cache.generateKey('refine', req.text, req.style, String(req.preserveVoice));
    const cached = this.cache.get(cacheKey) as LuminizeResponse | null;
    if (cached) return cached;

    const prompt = buildRefinePrompt(req);

    const rawResponse = await callGemini({
      systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
      contents: [{ role: 'user', parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.7,
        topP: 0.9,
        maxOutputTokens: 4096,
      },
    });

    const parsed = this.parseJSON<{
      refined: string;
      changes: LuminizeChange[];
      confidence: number;
    }>(rawResponse);

    const result: LuminizeResponse = {
      original: req.text,
      refined: parsed.refined || req.text,
      changes: parsed.changes || [],
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.7,
    };

    this.cache.set(cacheKey, result, CACHE_TTL_MS);
    return result;
  }

  // ---- Biomarker Translation ----

  async translateBiomarker(
    userId: string,
    req: { biomarkerName: string; value: number; unit: string; referenceRange?: { min?: number; max?: number } },
  ): Promise<{
    summary: string;
    explanation: string;
    status: 'optimal' | 'normal' | 'attention' | 'concern';
    suggestion: string | null;
  }> {
    this.checkRateLimit(userId);

    const cacheKey = this.cache.generateKey('biomarker', req.biomarkerName, String(req.value), req.unit);
    const cached = this.cache.get(cacheKey) as ReturnType<typeof this.translateBiomarker> extends Promise<infer R> ? R : never;
    if (cached) return cached;

    const prompt = buildBiomarkerPrompt(req);

    const rawResponse = await callGemini({
      systemInstruction: {
        parts: [{
          text: 'You are Luminize, the AI assistant for Resonance Wellness. Translate clinical biomarker data into warm, clear, empathetic language for patients. Never be alarmist. Always be truthful.',
        }],
      },
      contents: [{ role: 'user', parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.5,
        topP: 0.85,
        maxOutputTokens: 1024,
      },
    });

    const parsed = this.parseJSON<{
      summary: string;
      explanation: string;
      status: 'optimal' | 'normal' | 'attention' | 'concern';
      suggestion: string | null;
    }>(rawResponse);

    const result = {
      summary: parsed.summary || 'No summary available.',
      explanation: parsed.explanation || '',
      status: parsed.status || 'normal',
      suggestion: parsed.suggestion || null,
    };

    this.cache.set(cacheKey, result, CACHE_TTL_MS);
    return result;
  }

  // ---- Empathetic Response Drafting ----

  async draftEmpatheticResponse(
    userId: string,
    req: { incomingMessage: string; relationship: string; tone: string },
  ): Promise<{
    response: string;
    alternates: string[];
    emotionalRead: string;
  }> {
    this.checkRateLimit(userId);

    const cacheKey = this.cache.generateKey('empathy', req.incomingMessage, req.relationship, req.tone);
    const cached = this.cache.get(cacheKey) as ReturnType<typeof this.draftEmpatheticResponse> extends Promise<infer R> ? R : never;
    if (cached) return cached;

    const prompt = buildEmpathyPrompt(req);

    const rawResponse = await callGemini({
      systemInstruction: {
        parts: [{
          text: 'You are Luminize, helping users of Resonance craft thoughtful, genuine responses to messages. Your drafts should feel human, warm, and considerate — never robotic or formulaic.',
        }],
      },
      contents: [{ role: 'user', parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.8,
        topP: 0.9,
        maxOutputTokens: 2048,
      },
    });

    const parsed = this.parseJSON<{
      response: string;
      alternates: string[];
      emotionalRead: string;
    }>(rawResponse);

    const result = {
      response: parsed.response || 'I appreciate you sharing this with me.',
      alternates: Array.isArray(parsed.alternates) ? parsed.alternates.slice(0, 3) : [],
      emotionalRead: parsed.emotionalRead || '',
    };

    this.cache.set(cacheKey, result, CACHE_TTL_MS);
    return result;
  }

  // ---- JSON Parsing Helper ----

  private parseJSON<T>(raw: string): T {
    // Strip markdown code fences if present
    let cleaned = raw.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.slice(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.slice(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.slice(0, -3);
    }
    cleaned = cleaned.trim();

    try {
      return JSON.parse(cleaned) as T;
    } catch {
      // Try to extract JSON from the response
      const jsonMatch = cleaned.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        try {
          return JSON.parse(jsonMatch[0]) as T;
        } catch {
          throw new Error('Failed to parse AI response as JSON.');
        }
      }
      throw new Error('AI response did not contain valid JSON.');
    }
  }
}
