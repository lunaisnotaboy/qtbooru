import RubyPlugin from 'vite-plugin-ruby'
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    assetsInlineLimit: 0,
    sourcemap: process.env.NODE_ENV !== 'production' || process.env.RAILS_ENV !== 'production'
  },
  clearScreen: false,
  plugins: [
    RubyPlugin()
  ],
  resolve: {
    alias: {
      '@/': `${__dirname}/app/frontend/`
    }
  }
})
