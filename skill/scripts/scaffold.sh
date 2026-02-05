#!/bin/bash
# Scaffold a new POC project
# Usage: ./scaffold.sh <client-slug> <project-name>
# Example: ./scaffold.sh acme innovation-tracker-2026-02-04

set -e

CLIENT_SLUG="$1"
PROJECT_NAME="$2"

if [[ -z "$CLIENT_SLUG" || -z "$PROJECT_NAME" ]]; then
  echo "Usage: $0 <client-slug> <project-name>" >&2
  exit 1
fi

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/load-config.sh"

PROJECT_DIR="$POC_ROOT/$CLIENT_SLUG/$PROJECT_NAME"

if [[ -d "$PROJECT_DIR" ]]; then
  echo "ERROR: Directory already exists: $PROJECT_DIR" >&2
  exit 1
fi

echo "Creating POC at: $PROJECT_DIR"

mkdir -p "$PROJECT_DIR"/{app,lib}
cd "$PROJECT_DIR"

# .gitignore
cat > .gitignore << 'GITIGNORE'
# Dependencies
node_modules/
.pnp
.pnp.js

# Build
.next/
out/
build/
dist/

# Vercel
.vercel/

# Env
.env
.env.local
.env.*.local

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# TypeScript
*.tsbuildinfo
next-env.d.ts
GITIGNORE

# package.json
cat > package.json << EOF
{
  "name": "${CLIENT_SLUG}-poc",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "biome check .",
    "format": "biome format --write ."
  },
  "dependencies": {
    "next": "^15.1.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "tailwindcss": "^4.0.0",
    "@tailwindcss/postcss": "^4.0.0",
    "@vercel/analytics": "^1.4.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.6.0",
    "lucide-react": "^0.469.0",
    "framer-motion": "^11.15.0",
    "recharts": "^2.15.0"
  },
  "devDependencies": {
    "@biomejs/biome": "^1.9.0",
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "typescript": "^5.7.0"
  }
}
EOF

# tsconfig.json
cat > tsconfig.json << 'TSCONFIG'
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
TSCONFIG

# next.config.ts
cat > next.config.ts << 'NEXTCONFIG'
import type { NextConfig } from "next"

const nextConfig: NextConfig = {}

export default nextConfig
NEXTCONFIG

# postcss.config.mjs
cat > postcss.config.mjs << 'POSTCSS'
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
}

export default config
POSTCSS

# biome.json
cat > biome.json << 'BIOME'
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "organizeImports": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": { "recommended": true }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2
  }
}
BIOME

# lib/utils.ts
cat > lib/utils.ts << 'UTILS'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
UTILS

# lib/analytics.ts
cat > lib/analytics.ts << 'ANALYTICS'
import { track } from "@vercel/analytics"

/**
 * Track meaningful user interactions.
 * Vercel Analytics allows 2 properties per event.
 */
export function trackEvent(
  event: "cta_click" | "form_submit" | "feature_use" | "section_view",
  props: { name: string; value?: string }
) {
  track(event, props)
}
ANALYTICS

# app/globals.css - placeholder for Claude to fill in
cat > app/globals.css << 'GLOBALS'
@import "tailwindcss";

@theme {
  /* TODO: Replace with client brand colors */
  --color-primary: #3b82f6;
  --color-secondary: #6366f1;
  --color-accent: #8b5cf6;
  --color-background: #ffffff;
  --color-foreground: #0f172a;
  --color-muted: #f1f5f9;
  --color-border: #e2e8f0;

  /* TODO: Replace with client fonts */
  --font-heading: system-ui, sans-serif;
  --font-body: system-ui, sans-serif;

  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
}

@layer base {
  body {
    @apply bg-background text-foreground antialiased;
    font-family: var(--font-body);
  }

  h1, h2, h3, h4, h5, h6 {
    font-family: var(--font-heading);
  }
}

::selection {
  background: var(--color-primary);
  color: var(--color-background);
}
GLOBALS

# app/layout.tsx - placeholder for Claude to fill in
cat > app/layout.tsx << 'LAYOUT'
import type { Metadata } from "next"
import { Analytics } from "@vercel/analytics/react"
import "./globals.css"

export const metadata: Metadata = {
  title: "POC", // TODO: Replace with POC title
  description: "", // TODO: Replace with POC description
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
LAYOUT

# app/page.tsx - placeholder for Claude to fill in
cat > app/page.tsx << 'PAGE'
export default function Page() {
  return (
    <main className="min-h-screen">
      {/* TODO: Replace with POC content */}
    </main>
  )
}
PAGE

echo ""
echo "Scaffolded: $PROJECT_DIR"
echo ""
echo "Files created:"
find . -type f | sed 's|^./|  |' | sort
echo ""
echo "Next steps:"
echo "  1. Edit app/globals.css with client branding"
echo "  2. Edit app/layout.tsx with fonts and metadata"
echo "  3. Edit app/page.tsx with POC content"
