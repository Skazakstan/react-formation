"use client";
import styles from "@styles/components/navigation.module.css";
// import styles from "../styles/components/navigation.module.css";
import Link from "next/link";
import { useState, useRef, useEffect } from "react";

// module CSS to scope locally with styles
function Navigation() {
  const [openAuthMenu, setOpenAuthMenu] = useState<boolean>(false);
  const authMenuRef = useRef<HTMLUListElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        authMenuRef.current &&
        !authMenuRef.current.contains(event.target as Node)
      ) {
        setOpenAuthMenu(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  const toggleAuthMenu = () => {
    setOpenAuthMenu(!openAuthMenu);
  };

  const navLinks = [
    { href: "/", name: "Home" },
    { href: "/about", name: "About" },
    { href: "/docs", name: "Docs" },
    { href: "/shop", name: "Shop" },
    { href: "/portfolio", name: "Portfolio" },
    { href: "/order_product", name: "Order" },
  ];
  const authNavLinks = [
    { href: "/login", name: "Login" },
    { href: "/register", name: "Register" },
    { href: "/forgot-password", name: "Forgot Password ?" },
  ];
  const DownArrow = () => (
    <svg
      className="w-4 h-4 ml-1"
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M19 9l-7 7-7-7"
      />
    </svg>
  );

  return (
    <nav className={styles.container}>
      <ul className={styles.list}>
        {navLinks.map((link, index) => {
          return (
            <li key={index} className={styles.listItem}>
              <Link href={link.href}>{link.name}</Link>
            </li>
          );
        })}
        {/* Dropdown Menu Item */}
        <li className="relative">
          <button
            onClick={() => toggleAuthMenu()}
            className="flex items-center text-white hover:text-blue-600"
          >
            Auth
            <DownArrow />
          </button>

          {openAuthMenu && (
            <ul ref={authMenuRef} className={styles.authList}>
              {authNavLinks.map((link, index) => {
                return (
                  <li key={index} className={`px-4 py-2 ${styles.listItem}`}>
                    <Link href={link.href}>{link.name}</Link>
                  </li>
                );
              })}
            </ul>
          )}
        </li>
      </ul>
    </nav>
  );
}

export default Navigation;
