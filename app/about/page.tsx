import Image from "next/image";

const GEAR = [
  { item: "Body", detail: "Canon EOS 77D" },
  { item: "Podstawowy obiektyw", detail: "Canon EF 50mm f/1.8" },
  { item: "Zoom kit", detail: "Canon EF-S 18-55mm f/4-5.6 IS STM" },
  { item: "Telezoom", detail: "Sigma 70-300mm f/4-5.6 DG Macro" },
];

export default function AboutPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12">
      <h1 className="font-heading font-bold text-4xl md:text-5xl tracking-tight mb-8">
        O mnie
      </h1>

      <div className="grid md:grid-cols-2 gap-12">
        <div>
          <p className="font-body text-lg leading-relaxed text-text-secondary mb-6">
            Mam 17 lat i mieszkam w Nowym Sączu. Fotografią zajmuję się z pasji
            — od sportu, przez szkolne wydarzenia, po portrety i krajobrazy.
            Lubię łapać momenty takimi jakie są: bez ściemy, bez przesadnej
            obróbki.
          </p>

          <p className="font-body text-text-secondary mb-6">
            Poza zdjęciami interesuję się elektroniką. Kiedy nie mam aparatu w
            ręku, prawdopodobnie lutuję albo grzebię przy jakimś układzie.
          </p>

          <div className="border-t-2 border-border pt-6 mt-8">
            <h2 className="font-heading font-bold text-lg mb-4">Kontakt</h2>
            <div className="space-y-3 font-body">
              <div>
                <span className="text-sm uppercase tracking-wider text-text-secondary">
                  Telefon
                </span>
                <br />
                <a
                  href="tel:+484****9490"
                  className="font-heading font-bold text-lg hover:opacity-70"
                >
                  +48 453 289 490
                </a>
              </div>
              <div>
                <span className="text-sm uppercase tracking-wider text-text-secondary">
                  Email
                </span>
                <br />
                <a
                  href="mailto:ttdaveee@gmail.com"
                  className="font-heading font-bold text-lg hover:opacity-70"
                >
                  ttdaveee@gmail.com
                </a>
              </div>
            </div>
          </div>
        </div>

        <div>
          {/* Placeholder for Dawid's photo */}
          <div className="border-2 border-border aspect-square flex items-center justify-center bg-bg-dark text-white mb-8">
            <Image
              src="/avatar.jpg"
              alt="Dawid Kleszyk"
              width={400}
              height={400}
              className="object-cover w-full h-full"
            />
          </div>

          <h2 className="font-heading font-bold text-lg mb-4">Sprzęt</h2>
          <ul className="space-y-3">
            {GEAR.map(({ item, detail }) => (
              <li key={item} className="border-l-2 border-border-strong pl-4">
                <span className="font-body text-sm uppercase tracking-wider text-text-secondary">
                  {item}
                </span>
                <br />
                <span className="font-heading font-bold">{detail}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}
