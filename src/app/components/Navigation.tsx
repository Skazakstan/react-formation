"use client";
// import styles from "../styles/components/navigation.module.css";
// import styles from "@/app/styles/components/navigation.module.css";
import Link from "next/link";
import { useState } from "react";

// module CSS to scope locally with styles
function Navigation() {
  const [openAuthMenu, setOpenAuthMenu] = useState(false);
  console.log("state", { openAuthMenu });

  const toggleAuthMenu = () => {
    setOpenAuthMenu(openAuthMenu ? false : true);
  };

  const navLinks = [
    { href: "/", name: "Home" },
    { href: "/about", name: "About" },
    { href: "/docs", name: "Docs" },
    { href: "/shop", name: "Shop" },
    { href: "/portfolio", name: "Portfolio" },
  ];

  return (
    <nav className="p-[20px] bg-black">
      {/* <nav className={styles.container}> */}
      <ul className="flex justify-center items-center gap-5">
        {navLinks.map((link, index) => {
          return (
            <li key={index} className="text-white hover:text-blue-600">
              {/* <li key={index} className={styles.listItem}> */}
              <Link href={link.href}>{link.name}</Link>
            </li>
          );
        })}
        {/* Dropdown Menu Item */}
        <li className="relative">
          <button
            onClick={() => toggleAuthMenu()}
            className="flex items-center text-gray-700 hover:text-blue-600"
          >
            Auth
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
          </button>

          {openAuthMenu && (
            <ul className="absolute left-0 mt-2 w-48 bg-white rounded-md shadow-lg py-2 z-10">
              <li>
                <Link
                  href="/login"
                  className="block px-4 py-2 text-gray-700 hover:bg-blue-50"
                >
                  Login
                </Link>
              </li>
              <li>
                <Link
                  href="/register"
                  className="block px-4 py-2 text-gray-700 hover:bg-blue-50"
                >
                  Register
                </Link>
              </li>
              <li>
                <Link
                  href="/forgot-password"
                  className="block px-4 py-2 text-gray-700 hover:bg-blue-50"
                >
                  Forgot password ?
                </Link>
              </li>
            </ul>
          )}
        </li>
      </ul>
    </nav>
  );
}

export default Navigation;
