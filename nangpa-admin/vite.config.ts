import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import { ViteEjsPlugin } from 'vite-plugin-ejs';
import { splitVendorChunkPlugin } from 'vite';
import eslint from 'vite-plugin-checker';
import pluginRewriteAll from 'vite-plugin-rewrite-all';

// @ts-ignore
export default ({ command, mode }) => {
  return defineConfig({
    server: {
      host: 'localhost',
      port: 3001,
    },
    plugins: [
      pluginRewriteAll(),
      react({
        jsxImportSource: '@emotion/react',
        babel: {
          plugins: ['@emotion/babel-plugin'],
        },
      }),
      ViteEjsPlugin({
        ENVIRONMENT: loadEnv(mode, process.cwd()).VITE_ENV,
      }),
      splitVendorChunkPlugin(),
      eslint({
        typescript: {
          tsconfigPath: './tsconfig.json',
        },
        overlay: {
          position: 'bl',
        },
        eslint: {
          lintCommand: 'eslint --ignore-path .eslintignore  -c "./.eslintrc.json"  ./src/**/*.{ts,tsx} --cache=true ',
          dev: {
            logLevel: ['error'],
          },
        },
      }),
    ],
    define: {
      global: command === 'serve' ? 'window' : 'global',
    },
    build: {
      outDir: 'build',
    },
  });
};
