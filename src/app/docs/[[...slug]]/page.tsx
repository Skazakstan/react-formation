import type { TPageParams } from "@definitions";

type TSlugPageParam = { slug: string[] };

export async function generateStaticParams() {
  // Génère des routes statiques pour les chemins de documentation spécifiques
  return [
    // Page d'accueil de la documentation (sans slug)
    { slug: [] },
    // Pages de documentation de premier niveau
    { slug: ["getting-started"] },
    { slug: ["installation"] },
    { slug: ["tutorials"] },
    // Pages de documentation de deuxième niveau
    { slug: ["tutorials", "basic"] },
    { slug: ["tutorials", "advanced"] },
    { slug: ["api", "reference"] },
  ];
}

export default async function Docs(pageParams: TPageParams<TSlugPageParam>) {
  const { slug } = await pageParams.params;
  console.log("result", { slug });
  if (slug?.length > 0) {
    return (
      <>
        {slug.map((s, index) => (
          <h2 key={index}>{s}</h2>
        ))}
      </>
    );
  }
  return (
    <>
      <div className="w-full h-screen flex justify-center items-center">
        <h1 className="text-center text-slate-900 text-4xl my-6">
          DOCUMENTATION PAGE
        </h1>
      </div>
    </>
  );
}
