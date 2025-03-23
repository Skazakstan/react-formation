import { TProductPageParam } from "./product";

export type TReviewPageParam = {
  reviewId: string;
} & TProductPageParam;
