import Image from "next/image";

interface Photo {
  src: string;
  alt: string;
  width: number;
  height: number;
}

interface PhotoGridProps {
  photos: Photo[];
  onPhotoClick?: (index: number) => void;
}

export function PhotoGrid({ photos, onPhotoClick }: PhotoGridProps) {
  if (photos.length === 0) {
    return (
      <div className="text-center py-20">
        <p className="font-heading text-xl text-text-secondary">
          Portfolio jest puste
        </p>
        <p className="font-body text-text-secondary mt-2">
          Zdjęcia pojawią się tutaj wkrótce.
        </p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
      {photos.map((photo, i) => (
        <button
          key={photo.src}
          className="relative aspect-square overflow-hidden border border-border group"
          onClick={() => onPhotoClick?.(i)}
        >
          <Image
            src={photo.src}
            alt={photo.alt}
            fill
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            className="object-cover"
          />
          {/* Sharp black overlay on hover */}
          <div className="absolute inset-0 bg-black opacity-0 group-hover:opacity-30 transition-opacity duration-150" />
        </button>
      ))}
    </div>
  );
}
