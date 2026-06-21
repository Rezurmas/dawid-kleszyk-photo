import { createHmac, timingSafeEqual, randomBytes } from "crypto";
import { cookies } from "next/headers";

const COOKIE_NAME = "admin_session";
const MAX_AGE = 86400; // 24 godziny
const SEPARATOR = ".";

// Rate limiting: max 5 prób na 15 minut per IP
const loginAttempts = new Map<
  string,
  { count: number; firstAttempt: number }
>();

function getSecret(): string {
  const secret = process.env.AUTH_SECRET;
  if (!secret) {
    throw new Error("AUTH_SECRET env var required");
  }
  return secret;
}

function sign(payload: string): string {
  const hmac = createHmac("sha256", getSecret());
  hmac.update(payload);
  return payload + SEPARATOR + hmac.digest("base64url");
}

function verify(token: string): string | null {
  const idx = token.lastIndexOf(SEPARATOR);
  if (idx === -1) return null;

  const payload = token.slice(0, idx);
  const expectedSig = sign(payload);

  // Constant-time comparison
  const sigA = Buffer.from(token);
  const sigB = Buffer.from(expectedSig);

  if (sigA.length !== sigB.length) return null;
  if (!timingSafeEqual(sigA, sigB)) return null;

  // Check expiry (payload = "timestamp")
  const ts = parseInt(payload, 10);
  if (isNaN(ts) || Date.now() - ts > MAX_AGE * 1000) return null;

  return payload;
}

// ─── Server-side: create session ───

export async function createSession(): Promise<void> {
  const token = sign(Date.now().toString());
  const cookieStore = await cookies();
  cookieStore.set(COOKIE_NAME, token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: MAX_AGE,
  });
}

// ─── Server-side: destroy session ───

export async function destroySession(): Promise<void> {
  const cookieStore = await cookies();
  cookieStore.delete(COOKIE_NAME);
}

// ─── Server-side: check if authenticated ───

export async function isAuthenticated(): Promise<boolean> {
  const cookieStore = await cookies();
  const token = cookieStore.get(COOKIE_NAME)?.value;
  if (!token) return false;
  return verify(token) !== null;
}

// ─── Password verification ───

export function verifyPassword(input: string): boolean {
  const correct = process.env.ADMIN_PASSWORD;
  if (!correct) return false;

  // Constant-time comparison
  const a = Buffer.from(input.normalize(), "utf-8");
  const b = Buffer.from(correct.normalize(), "utf-8");

  if (a.length !== b.length) return false;
  return timingSafeEqual(a, b);
}

// ─── Rate limiting ───

const TRUSTED_IPS = new Set(["127.0.0.1", "::1", "localhost"]);

// Sprawdź czy IP jest z zaufanej sieci (192.168.x.x / 10.x.x.x / 172.16-31.x.x)
function isTrustedIP(ip: string): boolean {
  if (TRUSTED_IPS.has(ip)) return true;
  // Private networks
  if (ip.startsWith("192.168.")) return true;
  if (ip.startsWith("10.")) return true;
  if (/^172\.(1[6-9]|2\d|3[01])\./.test(ip)) return true;
  return false;
}

export function checkRateLimit(ip: string): boolean {
  // Bypass dla localhost i sieci prywatnych
  if (isTrustedIP(ip)) {
    return true;
  }

  const now = Date.now();
  const window = 5 * 60 * 1000; // 5 minut
  const maxAttempts = 10;

  const entry = loginAttempts.get(ip);

  if (!entry || now - entry.firstAttempt > window) {
    loginAttempts.set(ip, { count: 1, firstAttempt: now });
    return true;
  }

  if (entry.count >= maxAttempts) {
    return false;
  }

  entry.count++;
  return true;
}

// Cleanup co 5 minut
setInterval(() => {
  const cutoff = Date.now() - 10 * 60 * 1000;
  for (const [ip, entry] of loginAttempts) {
    if (entry.firstAttempt < cutoff) {
      loginAttempts.delete(ip);
    }
  }
}, 5 * 60 * 1000);
