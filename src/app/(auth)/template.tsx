"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

const navLinks = [
  { name: "Login", href: "/login" },
  { name: "Register", href: "/register" },
  { name: "Forgot password ?", href: "/forgot-password" },
];

export default function AuthLayout({
  // layout definition with children as node
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  /**
   * layout.tsx renamed template.tsx
   * layout
   *  -> structure de mise en page
   *  -> plusieurs pages
   *  -> ex. state ne change pas d'une page à lautre sur lememe template
   * template
   *  -> structure
   *  -> "encapsuler" des composants commun à plusieurs pages (barre latérales ou zone de contenu réutilisable)
   *  -> une seule page (en général)
   *  -> ex. state change d'une page à lautre sur lememe template
   *
   */
  const pathname = usePathname();
  const [state, setState] = useState("");
  const handleState = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value;
    setState(value);
  };
  return (
    <>
      <input
        type="text"
        className="border border-teal-900"
        value={state}
        onChange={handleState}
      />
      <ul>
        {navLinks.map((link, index) => {
          const isActive = pathname.startsWith(link.href);

          return (
            <li key={index}>
              <Link
                href={link.href}
                className={
                  isActive ? "text-red-600 font-bold" : "text-slate-500"
                }
              >
                {link.name}
              </Link>
            </li>
          );
        })}
      </ul>
      {children}
    </>
  );
}
