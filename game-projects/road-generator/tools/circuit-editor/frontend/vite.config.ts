import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// Le backend FastAPI tourne sur :8765 (CORS ouvert). api.ts y pointe directement
// (override possible via VITE_API). On proxifie quand même /api -> backend au cas où.
export default defineConfig({
  plugins: [svelte()],
  server: {
    port: 5180,
    proxy: { '/api': { target: 'http://127.0.0.1:8765', changeOrigin: true, rewrite: p => p.replace(/^\/api/, '') } },
  },
})
