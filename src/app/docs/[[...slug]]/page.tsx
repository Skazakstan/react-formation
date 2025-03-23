import type { TPageParams } from "@definitions";

type TSlugPageParam = { slug: string[] };

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
