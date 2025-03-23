import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Login",
};

export default function Login() {
  return (
    <>
      <div className="w-full flex justify-center items-center">
        <h1 className="text-center text-slate-900 text-4xl my-6">LOGIN PAGE</h1>
      </div>
      <div className="my-6">
        <p>Create a parent folder with parentthesis to groupe routes</p>
      </div>
    </>
  );
}
