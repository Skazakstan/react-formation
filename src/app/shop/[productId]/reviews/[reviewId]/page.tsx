import type { TPageParams, TReviewPageParam } from "@definitions";
import { notFound } from "next/navigation";

export default async function Review(
  parameters: TPageParams<TReviewPageParam>
) {
  const { productId, reviewId } = await parameters.params;

  if (parseInt(reviewId, 10) > 1000) {
    notFound();
  }

  return (
    <>
      <div className="w-full flex justify-center items-center">
        <h1 className="text-center text-slate-900 text-4xl my-6">
          REVIEW PAGE
        </h1>
      </div>
      <div className="w-full flex justify-center items-center">
        <h2 className="text-center text-slate-600 my-4">
          produit : {productId}
        </h2>
      </div>
      <div className="w-full flex justify-center items-center">
        <h2 className="text-center text-slate-600 my-4">review : {reviewId}</h2>
      </div>
    </>
  );
}
