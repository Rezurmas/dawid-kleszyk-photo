import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export default function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Tylko /admin/* (ale pozwól na /admin/login)
  if (!pathname.startsWith("/admin") || pathname === "/admin/login") {
    return NextResponse.next();
  }

  // API routes są sprawdzane wewnątrz handlera
  if (pathname.startsWith("/api/")) {
    return NextResponse.next();
  }

  // Sprawdź sesję — dla stron admina
  const sessionCookie = request.cookies.get("admin_session");
  if (!sessionCookie?.value) {
    return NextResponse.redirect(new URL("/admin/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/admin/:path*"],
};
