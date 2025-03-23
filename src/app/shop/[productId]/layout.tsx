export default function ProductLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <>
      <h2>je suis rajouté depuis le layout products</h2>
      <p>&quot;Nested Layout&quot;</p>
      <ul className="list-disc list-inside ml-5">
        <li>Permet d&apos;imbriqués les mises en page</li>
        <li>
          Structure application plus modulaire et réutilisable (logique de mise
          en page dans différents composants)
        </li>
        <li>mise en page réutilisable (nav, pied de page...)</li>
      </ul>
      {children}
    </>
  );
}
