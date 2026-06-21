"use client";

import Image from "next/image";
import { useEffect, useCallback } from "react";

interface LightboxProps {
  photos: { src: string; alt: string; width: number; height: number }[];
  currentIndex: number;
  onClose: () => void;
  onNext: () => void;
  onPrev: () => void;
}

export function Lightbox({
  photos,
  currentIndex,
  onClose,
  onNext,
  onPrev,
}: LightboxProps) {
  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
      if (e.key === "ArrowRight") onNext();
      if (e.key === "ArrowLeft") onPrev();
    },
    [onClose, onNext, onPrev]
  );

  useEffect(() => {
    document.addEventListener("keydown", handleKeyDown);
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = "";
    };
  }, [handleKeyDown]);

  const photo = photos[currentIndex];
  if (!photo) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black bg-opacity-95 flex items-center justify-center">
      {/* Close button */}
      <button
        className="absolute top-6 right-6 text-white font-heading text-2xl hover:opacity-70 z-10"
        onClick={onClose}
        aria-label="Zamknij"
      >
        &#10005;
      </button>

      {/* Counter */}
      <span className="absolute top-6 left-6 text-white font-heading text-sm uppercase tracking-wider z-10">
        {currentIndex + 1} / {photos.length}
      </span>

      {/* Prev */}
      <button
        className="absolute left-4 text-white font-heading text-4xl hover:opacity-70 z-10 px-4 py-8"
        onClick={onPrev}
        aria-label="Poprzednie"
      >
        &#8249;
      </button>

      {/* Image */}
      <div className="relative w-full max-w-4xl max-h-[80vh] mx-16">
        <Image
          src={photo.src}
          alt={photo.alt}
          width={photo.width}
          height={photo.height}
          className="object-contain w-full h-full"
          priority
        />
      </div>

      {/* Next */}
      <button
        className="absolute right-4 text-white font-heading text-4xl hover:opacity-70 z-10 px-4 py-8"
        onClick={onNext}
        aria-label="Następne"
      >
        &#8250;
      </button>
    </div>
  );
}
