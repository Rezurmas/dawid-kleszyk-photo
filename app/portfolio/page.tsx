"use client";

import { useState } from "react";
import { PhotoGrid } from "@/components/PhotoGrid";
import { Lightbox } from "@/components/Lightbox";

// TODO: Replace with real data from database/filesystem later
const SAMPLE_PHOTOS = [
  { src: "/uploads/placeholder-1.jpg", alt: "Portret 1", width: 800, height: 800 },
  { src: "/uploads/placeholder-2.jpg", alt: "Sport 1", width: 800, height: 600 },
  { src: "/uploads/placeholder-3.jpg", alt: "Event 1", width: 600, height: 800 },
];

export default function PortfolioPage() {
  const [lightboxOpen, setLightboxOpen] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);

  return (
    <div className="max-w-6xl mx-auto px-6 py-12">
      <h1 className="font-heading font-bold text-4xl md:text-5xl tracking-tight mb-2">
        Portfolio
      </h1>
      <p className="font-body text-text-secondary mb-10">
        Wybrane zdjęcia z różnych sesji.
      </p>

      <PhotoGrid
        photos={SAMPLE_PHOTOS}
        onPhotoClick={(i) => {
          setCurrentIndex(i);
          setLightboxOpen(true);
        }}
      />

      {lightboxOpen && (
        <Lightbox
          photos={SAMPLE_PHOTOS}
          currentIndex={currentIndex}
          onClose={() => setLightboxOpen(false)}
          onNext={() =>
            setCurrentIndex((p) => Math.min(p + 1, SAMPLE_PHOTOS.length - 1))
          }
          onPrev={() => setCurrentIndex((p) => Math.max(p - 1, 0))}
        />
      )}
    </div>
  );
}
