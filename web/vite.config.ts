/**
 * Vite configuration for Resonance UX Web
 *
 * - React plugin with automatic JSX runtime
 * - PWA via vite-plugin-pwa (Workbox)
 * - Path aliases for clean imports
 * - Optimized chunking strategy
 */

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import { resolve } from 'path';

export default defineConfig(({ mode }) => {
  const isProd = mode === 'production';

  return {
    plugins: [
      react({
        jsxImportSource: 'react',
      }),

      VitePWA({
        registerType: 'autoUpdate',
        includeAssets: [
          'favicon.ico',
          'apple-touch-icon.png',
          'resonance-icon-192.png',
          'resonance-icon-512.png',
        ],
        manifest: false, // We provide our own manifest.json in /public
        workbox: {
          globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
          runtimeCaching: [
            {
              // Google Fonts CSS
              urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
              handler: 'StaleWhileRevalidate',
              options: {
                cacheName: 'google-fonts-stylesheets',
                expiration: { maxEntries: 10, maxAgeSeconds: 60 * 60 * 24 * 365 },
              },
            },
            {
              // Google Fonts files
              urlPattern: /^https:\/\/fonts\.gstatic\.com\/.*/i,
              handler: 'CacheFirst',
              options: {
                cacheName: 'google-fonts-webfonts',
                expiration: { maxEntries: 30, maxAgeSeconds: 60 * 60 * 24 * 365 },
                cacheableResponse: { statuses: [0, 200] },
              },
            },
            {
              // API calls — network first with fallback
              urlPattern: /^\/api\/.*/i,
              handler: 'NetworkFirst',
              options: {
                cacheName: 'api-cache',
                networkTimeoutSeconds: 10,
                expiration: { maxEntries: 100, maxAgeSeconds: 60 * 60 },
                cacheableResponse: { statuses: [0, 200] },
              },
            },
            {
              // Images
              urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp)$/i,
              handler: 'CacheFirst',
              options: {
                cacheName: 'images',
                expiration: { maxEntries: 60, maxAgeSeconds: 60 * 60 * 24 * 30 },
              },
            },
          ],
        },
      }),
    ],

    resolve: {
      alias: {
        '@': resolve(__dirname, 'src'),
        '@components': resolve(__dirname, 'src/components'),
        '@theme': resolve(__dirname, 'src/theme'),
        '@shared': resolve(__dirname, '..', 'shared'),
      },
    },

    server: {
      port: 3000,
      strictPort: false,
      proxy: {
        '/api': {
          target: 'http://localhost:4000',
          changeOrigin: true,
        },
        '/ws': {
          target: 'ws://localhost:4000',
          ws: true,
        },
      },
    },

    preview: {
      port: 3001,
    },

    build: {
      target: 'es2022',
      outDir: 'dist',
      sourcemap: isProd ? 'hidden' : true,
      minify: isProd ? 'esbuild' : false,
      rollupOptions: {
        output: {
          manualChunks: {
            vendor: ['react', 'react-dom', 'react-router-dom'],
            motion: ['framer-motion'],
          },
        },
      },
      chunkSizeWarningLimit: 500,
    },

    css: {
      postcss: {
        plugins: [],
      },
    },

    define: {
      __APP_VERSION__: JSON.stringify(process.env.npm_package_version ?? '1.0.0'),
    },
  };
});
