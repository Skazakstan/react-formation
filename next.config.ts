import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  /* static site generation */
  output: "export", // Désactive les fonctionnalités serveur
  images: { unoptimized: true },
  // Optional: Create folder structure with index.html files
  basePath: '',
  trailingSlash: true,
};

export default nextConfig;
