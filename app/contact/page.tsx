import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Kontakt",
};

export default function ContactPage() {
  return (
    <div className="max-w-2xl mx-auto px-6 py-24 text-center">
      <h1 className="font-heading font-bold text-4xl md:text-5xl tracking-tight mb-6">
        Kontakt
      </h1>
      <p className="font-body text-lg text-text-secondary mb-16 max-w-md mx-auto">
        Potrzebujesz fotografa? Napisz lub zadzwoń — dogadamy się.
      </p>

      <div className="space-y-12">
        <div>
          <p className="font-body text-sm uppercase tracking-wider text-text-secondary mb-2">
            Telefon
          </p>
          <a
            href="tel:+484****9490"
            className="font-heading font-bold text-3xl md:text-4xl tracking-tight hover:opacity-70"
          >
            +48 453 289 490
          </a>
        </div>

        <div>
          <p className="font-body text-sm uppercase tracking-wider text-text-secondary mb-2">
            Email
          </p>
          <a
            href="mailto:ttdaveee@gmail.com"
            className="font-heading font-bold text-2xl md:text-3xl tracking-tight hover:opacity-70"
          >
            ttdaveee@gmail.com
          </a>
        </div>
      </div>

      <div className="mt-20 pt-12 border-t-2 border-border">
        <p className="font-body text-text-secondary">
          Sesje: sport, szkoła, portrety, eventy, krajobrazy
          <br />
          Nowy Sącz i okolice
        </p>
      </div>
    </div>
  );
}
