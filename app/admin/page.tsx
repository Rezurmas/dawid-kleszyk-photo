import { isAuthenticated } from "@/lib/auth";
import { redirect } from "next/navigation";
import { AdminDashboard } from "@/components/AdminDashboard";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Panel admina",
  robots: "noindex, nofollow",
};

export default async function AdminPage() {
  const authed = await isAuthenticated();
  if (!authed) {
    redirect("/admin/login");
  }

  return (
    <div className="max-w-3xl mx-auto px-6 py-12">
      <h1 className="font-heading font-bold text-4xl tracking-tight mb-8">
        Panel admina
      </h1>
      <AdminDashboard />
    </div>
  );
}
