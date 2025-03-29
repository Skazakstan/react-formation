import React from "react";
import type { TPageParams, TProductPageParam } from "@definitions";

export async function generateStaticParams() {
  // Retourne un tableau d'objets avec les valeurs de productId pour lesquelles
  // des pages statiques seront générées lors du build
  return [
    { productId: "1" },
    { productId: "2" },
    { productId: "3" },
    { productId: "4" },
    { productId: "5" },
  ];
}

export default async function Product(
  parameters: TPageParams<TProductPageParam>
) {
  const { productId } = await parameters.params;

  return (
    <>
      <div className="w-full h-screen flex justify-center items-center">
        <h1 className="text-center text-slate-900 text-4xl my-6">
          PRODUCT PAGE: {productId}
        </h1>
      </div>
    </>
  );
}
