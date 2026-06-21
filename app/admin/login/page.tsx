import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Admin — logowanie",
  robots: "noindex, nofollow",
};

export default function AdminLoginPage() {
  return (
    <div className="max-w-md mx-auto px-6 py-24">
      <h1 className="font-heading font-bold text-4xl tracking-tight mb-2">
        Admin
      </h1>
      <p className="font-body text-text-secondary mb-10">
        Wprowadź hasło, żeby przejść do panelu.
      </p>

      <form action="/api/admin/login" method="POST" className="space-y-6">
        <div>
          <label
            htmlFor="password"
            className="block font-heading font-medium text-sm uppercase tracking-wider mb-2"
          >
            Hasło
          </label>
          <input
            id="password"
            name="password"
            type="password"
            required
            autoComplete="current-password"
            className="w-full border-2 border-border bg-white px-4 py-3 font-body text-text placeholder:text-text-secondary focus:border-border-strong focus:outline-none"
            placeholder="••••••••"
          />
        </div>

        <button
          type="submit"
          className="w-full font-heading font-bold text-sm uppercase tracking-wider bg-text text-white border-2 border-text px-6 py-4 hover:opacity-70"
        >
          Zaloguj
        </button>
      </form>
    </div>
  );
}
