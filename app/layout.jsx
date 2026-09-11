import "./globals.css";

export const metadata = {
  title: "ATRI RPA | Passo 1",
  description: "Painel operacional do fluxo de consolidacao",
};

export default function RootLayout({ children }) {
  return (
    <html lang="pt-BR">
      <body>{children}</body>
    </html>
  );
}
