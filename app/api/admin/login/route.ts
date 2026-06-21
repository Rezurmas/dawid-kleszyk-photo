import { NextResponse } from "next/server";
import { verifyPassword, createSession, checkRateLimit } from "@/lib/auth";

export async function POST(request: Request) {
  const ip =
    request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ||
    request.headers.get("x-real-ip") ||
    "127.0.0.1";

  // Rate limit
  if (!checkRateLimit(ip)) {
    return NextResponse.json(
      { error: "Za dużo prób. Spróbuj ponownie za 15 minut." },
      { status: 429 }
    );
  }

  try {
    const formData = await request.formData();
    const password = formData.get("password") as string;

    if (!password || !verifyPassword(password)) {
      return NextResponse.json(
        { error: "Nieprawidłowe hasło." },
        { status: 401 }
      );
    }

    await createSession();
    return NextResponse.redirect(new URL("/admin", request.url), 303);
  } catch {
    return NextResponse.json({ error: "Błąd serwera." }, { status: 500 });
  }
}
