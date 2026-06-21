import Link from "next/link";

const NAV_LINKS = [
  { href: "/", label: "Home" },
  { href: "/portfolio", label: "Portfolio" },
  { href: "/about", label: "O mnie" },
];

export function Navbar() {
  return (
    <header className="bg-bg-dark text-white border-b-2 border-border-strong">
      <div className="max-w-6xl mx-auto px-6 py-4 flex justify-between items-center">
        <Link
          href="/"
          className="font-heading font-bold text-xl tracking-tight hover:opacity-70"
        >
          DAWID KLESZYK
        </Link>

        <nav className="flex items-center gap-8">
          {NAV_LINKS.map(({ href, label }) => (
            <Link
              key={href}
              href={href}
              className="font-heading font-medium text-sm uppercase tracking-wider hover:opacity-70"
            >
              {label}
            </Link>
          ))}
          <Link
            href="/contact"
            className="font-heading font-medium text-sm uppercase tracking-wider border-2 border-white px-4 py-1 hover:bg-white hover:text-black hover:opacity-100"
          >
            Kontakt
          </Link>
        </nav>
      </div>
    </header>
  );
}
