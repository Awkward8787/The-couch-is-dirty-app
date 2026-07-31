import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";
import { sessionCookieName } from "@/lib/appwrite/config";
import { ADMIN_USER_ID_COOKIE } from "@/lib/auth/constants";

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  if (pathname.startsWith("/login") || pathname.startsWith("/api/")) {
    return NextResponse.next();
  }

  const session = request.cookies.get(sessionCookieName());
  const userId = request.cookies.get(ADMIN_USER_ID_COOKIE);
  if (!session?.value || !userId?.value) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|podcast-logo.png).*)"],
};
