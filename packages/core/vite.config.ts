import { defineConfig } from 'vitest/config';
import createReScriptPlugin from '@jihchi/vite-plugin-rescript';

export default defineConfig({
  plugins: [createReScriptPlugin()],
  test: {
    includeSource: ['src/**/*.{js,ts}'],
  },
});
