# POC Schemas

## Meeting Extraction Schema

```json
{
  "client": {
    "name": "Company name",
    "slug": "company-name (lowercase, hyphens)",
    "contact_name": "Person we spoke with",
    "contact_email": "email if available",
    "website": "https://... (from email domain or mentioned)"
  },
  "poc": {
    "type": "prototype | workflow | landing-page | dashboard | form",  // workflow/form → Supabase; chat/analysis → OpenRouter
    "title": "Short descriptive title",
    "problem": "What problem are we solving",
    "solution": "What we're building to demonstrate",
    "key_features": ["feature 1", "feature 2", "feature 3"],
    "target_user": "Who will use this",
    "success_criteria": "How client will evaluate this"
  },
  "context": {
    "industry": "Client's industry",
    "timeline": "Any mentioned deadlines",
    "constraints": "Technical or business constraints mentioned",
    "next_steps": "Agreed follow-up actions"
  }
}
```

## Branding Schema

Extract from client website. Use fallback values if unavailable.

```json
{
  "colors": {
    "primary": "#...",
    "secondary": "#...",
    "accent": "#...",
    "background": "#ffffff",
    "foreground": "#0f172a",
    "muted": "#f1f5f9",
    "border": "#e2e8f0"
  },
  "fonts": {
    "heading": "Font name",
    "body": "Font name"
  },
  "aesthetic": "minimal | corporate | playful | luxury | tech"
}
```

**Fallback values** (when website unreachable):
- primary: `#0f172a`
- secondary: `#334155`
- accent: `#3b82f6`
- fonts: DM Sans
- aesthetic: Clean, professional, modern

## Research Synthesis Schema

```
TARGET USER: [persona summary]
PRIMARY JTBD: [main job statement]
KEY PAINS TO ADDRESS: [top 2-3 pains]
SUCCESS LOOKS LIKE: [gains they'll experience]
DIFFERENTIATION: [what makes this approach better]
```
