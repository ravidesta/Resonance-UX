// MARK: - Luminous Journey™ Web App Root Layout

import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Luminous Journey — Constructive Development™',
  description: 'Subject-Object and the Evolution of Meaning. A transformative journey through human development. Read, listen, practice, reflect.',
  keywords: ['developmental psychology', 'subject-object', 'Kegan', 'meaning-making', 'somatic awareness', 'Luminous Constructive Development'],
  openGraph: {
    title: 'Luminous Constructive Development™',
    description: 'Subject-Object and the Evolution of Meaning',
    type: 'website',
    siteName: 'Luminous Journey',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Luminous Constructive Development™',
    description: 'A transformative journey through the landscape of human development.',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;1,300;1,400&family=Manrope:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body style={{ margin: 0 }}>{children}</body>
    </html>
  );
}
