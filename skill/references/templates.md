# Project Templates

Use these templates when creating the POC project structure.

## Contents

- [.gitignore](#gitignore)
- [package.json](#packagejson)
- [tsconfig.json](#tsconfigjson)
- [next.config.ts](#nextconfigts)
- [postcss.config.mjs](#postcssconfigmjs)
- [biome.json](#biomejson)
- [lib/utils.ts](#libutilsts)
- [lib/analytics.ts](#libanalyticsts)
- [app/globals.css](#appglobalscss)
- [app/layout.tsx](#applayouttsx)
- [app/page.tsx](#apppagetsx)

## .gitignore

```
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
```

## package.json

```json
{
  "name": "{{CLIENT_SLUG}}-poc",
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
```

## tsconfig.json

```json
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
```

## next.config.ts

```ts
import type { NextConfig } from "next"

const nextConfig: NextConfig = {}

export default nextConfig
```

## postcss.config.mjs

```js
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
}

export default config
```

## biome.json

```json
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
```

## lib/utils.ts

```ts
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

## lib/analytics.ts

```ts
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

// Usage examples:
// trackEvent("cta_click", { name: "get_started" })
// trackEvent("form_submit", { name: "contact", value: "success" })
// trackEvent("feature_use", { name: "filter", value: "date_range" })
// trackEvent("section_view", { name: "pricing" })
```

## app/globals.css

Tailwind 4 uses CSS-first configuration:

```css
@import "tailwindcss";

@theme {
  --color-primary: {{PRIMARY_COLOR}};
  --color-secondary: {{SECONDARY_COLOR}};
  --color-accent: {{ACCENT_COLOR}};
  --color-background: {{BACKGROUND_COLOR}};
  --color-foreground: {{FOREGROUND_COLOR}};
  --color-muted: {{MUTED_COLOR}};
  --color-border: {{BORDER_COLOR}};

  --font-heading: var(--font-{{HEADING_FONT_VAR}}), system-ui, sans-serif;
  --font-body: var(--font-{{BODY_FONT_VAR}}), system-ui, sans-serif;

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
```

## app/layout.tsx

```tsx
import type { Metadata } from "next"
import { {{HEADING_FONT_IMPORT}}, {{BODY_FONT_IMPORT}} } from "next/font/google"
import { Analytics } from "@vercel/analytics/react"
import "./globals.css"

const headingFont = {{HEADING_FONT_INIT}}
const bodyFont = {{BODY_FONT_INIT}}

export const metadata: Metadata = {
  title: "{{POC_TITLE}} | {{CLIENT_NAME}}",
  description: "{{POC_DESCRIPTION}}",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={`${headingFont.variable} ${bodyFont.variable}`}>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
```

### Font initialization example

Replace placeholders based on detected fonts:

```tsx
// For DM Sans heading and Inter body:
import { DM_Sans, Inter } from "next/font/google"

const headingFont = DM_Sans({
  subsets: ["latin"],
  variable: "--font-heading",
  weight: ["400", "500", "600", "700"]
})
const bodyFont = Inter({
  subsets: ["latin"],
  variable: "--font-body"
})
```

## app/page.tsx

The main page component. Replace `{{POC_COMPONENT}}` with generated POC content.

```tsx
import { trackEvent } from "@/lib/analytics"

export default function Page() {
  return (
    <main className="min-h-screen">
      {/* {{POC_COMPONENT}} - Replace with generated POC content */}
    </main>
  )
}
```

### Example: Landing page structure

```tsx
"use client"

import { motion } from "framer-motion"
import { trackEvent } from "@/lib/analytics"

export default function Page() {
  return (
    <main className="min-h-screen">
      {/* Hero */}
      <section className="py-24 px-6">
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-5xl font-heading font-bold"
        >
          {{HEADLINE}}
        </motion.h1>
        <button
          onClick={() => trackEvent("cta_click", { name: "hero_cta" })}
          className="mt-8 px-6 py-3 bg-primary text-background rounded-md"
        >
          {{CTA_TEXT}}
        </button>
      </section>

      {/* Features */}
      <section
        className="py-24 px-6 bg-muted"
        onMouseEnter={() => trackEvent("section_view", { name: "features" })}
      >
        {/* Feature cards */}
      </section>
    </main>
  )
}
```
