import { NextResponse } from "next/server";
import { isAuthenticated } from "@/lib/auth";
import { writeFile, mkdir } from "fs/promises";
import path from "path";

const UPLOAD_DIR = path.join(process.cwd(), "public", "uploads");
const ALLOWED_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);
const MAX_SIZE = 10 * 1024 * 1024; // 10 MB
const MAX_FILES = 10;

// Sanitize filename: only keep alphanumeric, dots, dashes, underscores
function sanitize(name: string): string {
  return name.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 100);
}

export async function POST(request: Request) {
  // Auth check
  const authed = await isAuthenticated();
  if (!authed) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Limit request size
  const contentLength = Number(
    request.headers.get("content-length") || "0"
  );
  if (contentLength > MAX_SIZE * MAX_FILES) {
    return NextResponse.json({ error: "Za duże dane." }, { status: 413 });
  }

  try {
    const formData = await request.formData();
    const entries = formData.getAll("files");

    if (entries.length === 0) {
      return NextResponse.json({ error: "Brak plików." }, { status: 400 });
    }
    if (entries.length > MAX_FILES) {
      return NextResponse.json(
        { error: `Max ${MAX_FILES} plików naraz.` },
        { status: 400 }
      );
    }

    await mkdir(UPLOAD_DIR, { recursive: true });

    let uploaded = 0;
    for (const entry of entries) {
      if (!(entry instanceof File)) continue;
      if (!ALLOWED_TYPES.has(entry.type)) continue;
      if (entry.size > MAX_SIZE) continue;

      const buffer = Buffer.from(await entry.arrayBuffer());
      const safeName = sanitize(entry.name);
      const timestamp = Date.now();
      const filePath = path.join(UPLOAD_DIR, `${timestamp}_${safeName}`);

      await writeFile(filePath, buffer);
      uploaded++;
    }

    return NextResponse.json({ success: true, count: uploaded });
  } catch (error) {
    console.error("Upload error:", error);
    return NextResponse.json({ error: "Błąd uploadu." }, { status: 500 });
  }
}
