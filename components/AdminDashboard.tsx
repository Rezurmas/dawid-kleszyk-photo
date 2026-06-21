"use client";

import { useState, useRef } from "react";
import { useRouter } from "next/navigation";

export function AdminDashboard() {
  const [uploading, setUploading] = useState(false);
  const [message, setMessage] = useState("");
  const [previews, setPreviews] = useState<string[]>([]);
  const [files, setFiles] = useState<File[]>([]);
  const fileRef = useRef<HTMLInputElement>(null);
  const router = useRouter();

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const selected = Array.from(e.target.files || []);
    setFiles(selected);
    setPreviews(selected.map((f) => URL.createObjectURL(f)));
    setMessage("");
  }

  async function handleUpload() {
    if (files.length === 0) return;
    setUploading(true);
    setMessage("");

    try {
      const formData = new FormData();
      files.forEach((f) => formData.append("files", f));

      const res = await fetch("/api/upload", {
        method: "POST",
        body: formData,
      });

      const json = await res.json();

      if (res.ok) {
        setMessage(`Dodano ${json.count} zdjęć.`);
        setFiles([]);
        setPreviews([]);
        if (fileRef.current) fileRef.current.value = "";
      } else if (res.status === 401) {
        setMessage("Sesja wygasła. Odśwież stronę.");
      } else {
        setMessage(json.error || "Błąd uploadu.");
      }
    } catch {
      setMessage("Błąd połączenia.");
    } finally {
      setUploading(false);
    }
  }

  async function handleLogout() {
    await fetch("/api/admin/logout", { method: "POST" });
    router.push("/");
  }

  return (
    <div className="space-y-12">
      <section>
        <h2 className="font-heading font-bold text-2xl tracking-tight mb-2">
          Prześlij zdjęcia
        </h2>
        <p className="font-body text-text-secondary mb-6">
          Zdjęcia trafią do portfolio. Dozwolone: JPG, PNG, WebP. Max 10 MB na
          plik.
        </p>

        <div className="space-y-4">
          <input
            ref={fileRef}
            type="file"
            accept="image/jpeg,image/png,image/webp"
            multiple
            onChange={handleFileChange}
            className="w-full border-2 border-border bg-white px-4 py-3 font-body text-text file:font-heading file:uppercase file:text-sm file:border-2 file:border-text file:bg-white file:text-text file:px-4 file:py-2 file:mr-4 hover:file:bg-text hover:file:text-white"
          />

          {previews.length > 0 && (
            <div className="grid grid-cols-3 gap-1">
              {previews.map((url, i) => (
                <div
                  key={i}
                  className="aspect-square border border-border overflow-hidden"
                >
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={url}
                    alt={`Preview ${i + 1}`}
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
            </div>
          )}

          {files.length > 0 && (
            <button
              onClick={handleUpload}
              disabled={uploading}
              className="w-full font-heading font-bold text-sm uppercase tracking-wider bg-text text-white border-2 border-text px-6 py-4 hover:opacity-70 disabled:opacity-50"
            >
              {uploading
                ? "Przesyłanie…"
                : `Prześlij ${files.length} zdjęć`}
            </button>
          )}

          {message && (
            <p
              className={`font-body text-sm ${
                message.startsWith("Dodano")
                  ? "text-green-700"
                  : "text-text-secondary"
              }`}
            >
              {message}
            </p>
          )}
        </div>
      </section>

      <hr className="border-border" />

      <section className="text-center">
        <button
          onClick={handleLogout}
          className="font-heading font-medium text-sm uppercase tracking-wider text-text-secondary hover:text-text hover:opacity-70"
        >
          Wyloguj
        </button>
      </section>
    </div>
  );
}
