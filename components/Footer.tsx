export function Footer() {
  return (
    <footer className="bg-bg-dark text-text-secondary border-t-2 border-border-strong mt-20">
      <div className="max-w-6xl mx-auto px-6 py-8 flex flex-col md:flex-row justify-between items-center gap-4">
        <p className="font-body text-sm">
          &copy; {new Date().getFullYear()} Dawid Kleszyk &mdash; Fotografia
          Nowy Sącz
        </p>
        <div className="flex gap-6 font-heading text-xs uppercase tracking-wider">
          <a
            href="mailto:ttdaveee@gmail.com"
            className="hover:text-white hover:opacity-70"
          >
            Email
          </a>
          <a href="tel:+48453289490" className="hover:text-white hover:opacity-70">
            +48 453 289 490
          </a>
          <a
            href="https://instagram.com"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-white hover:opacity-70"
          >
            Instagram
          </a>
        </div>
      </div>
    </footer>
  );
}
