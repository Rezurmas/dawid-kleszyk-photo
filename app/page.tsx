import Link from "next/link";

export default function HomePage() {
  return (
    <>
      {/* Hero */}
      <section className="relative border-b-2 border-border-strong">
        <div className="max-w-6xl mx-auto px-6 py-24 md:py-40">
          <h1 className="font-heading font-bold text-5xl md:text-7xl tracking-tight leading-none">
            Dawid
            <br />
            Kleszyk
          </h1>
          <p className="font-body text-xl text-text-secondary mt-6 max-w-lg">
            Fotografia z pasją. Sport, portrety, eventy — Nowy Sącz i okolice.
          </p>
          <div className="flex gap-4 mt-10">
            <Link
              href="/portfolio"
              className="font-heading font-bold text-sm uppercase tracking-wider bg-text text-white border-2 border-text px-8 py-4 hover:opacity-70"
            >
              Zobacz portfolio
            </Link>
            <Link
              href="/contact"
              className="font-heading font-bold text-sm uppercase tracking-wider border-2 border-text px-8 py-4 hover:bg-text hover:text-white hover:opacity-100"
            >
              Napisz do mnie
            </Link>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="max-w-6xl mx-auto px-6 py-24 grid grid-cols-1 md:grid-cols-3 gap-12">
        <div className="border-l-2 border-border-strong pl-6">
          <h3 className="font-heading font-bold text-lg mb-2">Sport</h3>
          <p className="font-body text-text-secondary text-sm">
            Dynamiczne ujęcia z boiska, bieżni i hali. Akcja zatrzymana w
            kadrze.
          </p>
        </div>
        <div className="border-l-2 border-border-strong pl-6">
          <h3 className="font-heading font-bold text-lg mb-2">Portrety</h3>
          <p className="font-body text-text-secondary text-sm">
            Naturalne światło, czyste tło. Ty i twoja historia — bez zbędnych
            sztuczek.
          </p>
        </div>
        <div className="border-l-2 border-border-strong pl-6">
          <h3 className="font-heading font-bold text-lg mb-2">Eventy</h3>
          <p className="font-body text-text-secondary text-sm">
            Wydarzenia szkolne, zawody, imprezy. Dokumentacja bez zakłócania
            atmosfery.
          </p>
        </div>
      </section>

      {/* CTA strip */}
      <section className="bg-bg-dark text-white border-t-2 border-b-2 border-border-strong">
        <div className="max-w-6xl mx-auto px-6 py-16 text-center">
          <h2 className="font-heading font-bold text-3xl md:text-4xl tracking-tight mb-4">
            Masz projekt w głowie?
          </h2>
          <p className="font-body text-text-secondary mb-8">
            Napisz — pogadamy co da się zrobić.
          </p>
          <Link
            href="/contact"
            className="inline-block font-heading font-bold text-sm uppercase tracking-wider border-2 border-white px-8 py-4 hover:bg-white hover:text-black hover:opacity-100"
          >
            Kontakt
          </Link>
        </div>
      </section>
    </>
  );
}
