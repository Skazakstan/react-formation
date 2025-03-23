import Link from "next/link";

const navLinks = [
  { name: "Login", href: "/login" },
  { name: "Register", href: "/register" },
  { name: "Forgot password ?", href: "/forgot-password" },
];
export default function AuthLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <>
      <ul>
        {navLinks.map((link, index) => {
          return (
            <li key={index}>
              <Link href={link.href}>{link.name}</Link>
            </li>
          );
        })}
      </ul>
      {children}
    </>
  );
}
