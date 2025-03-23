export type TPageParams<P = void, S = void> = {
  params: Promise<P>;
  searchParams: Promise<S>;
};
