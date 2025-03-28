"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

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
  const pathname = usePathname();
  return (
    <>
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
