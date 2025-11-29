import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: '/',  // Opens index.html when server starts
    host: true  // Allows access from network
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  }
})

