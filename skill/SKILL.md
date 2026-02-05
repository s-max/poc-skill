---
name: poc
description: >-
  Generate a proof-of-concept from a client call transcript via Granola MCP.
  Use when the user says "/poc", "build poc from call", "create demo for client",
  or wants to turn a meeting into a working prototype.
  Modes: (1) "/poc" or "/poc [client]" - extract idea from meeting,
  (2) "/poc ideas" or "/poc [client] brainstorm" - get 3 POC ideas first,
  (3) "/poc [client] [idea description]" - build specific idea with meeting context
  (e.g., "/poc acme Innovation Radar - market intelligence dashboard").
---

# POC Generator

Generate a branded POC from a Granola client call transcript.

## Installation

Run once: `<skill-dir>/scripts/install.sh`

Creates config at `~/.config/poc/config.json` and sets up project permissions.

## Command Execution Rule

**Run each bash command separately.** Never chain with `&&`, `||`, or `;` - permissions block compound commands.

## Workflow

### Step 0: Initialize

Verify prerequisites (see [references/prerequisites.md](references/prerequisites.md)).

**Check Granola auth first** - run `mcp__granola__list_meetings`. If auth error, tell user to run `/mcp` and re-authenticate via browser.

Load config:

```bash
source <skill-dir>/scripts/load-config.sh
```

Exports: `POC_SKILL_DIR`, `POC_ROOT`, `POC_VERCEL_SCOPE`, `POC_ALIAS_DOMAIN`.

Parse input to determine mode:

| Pattern | Mode |
|---------|------|
| Empty or single word | Meeting-driven |
| Contains "ideas" or "brainstorm" | Ideation (present 3 options) |
| `<client> <description>` | Direct idea |

### Step 1: Get Meeting

```
mcp__granola__list_meetings              # Scan meetings: ID, title, date, attendees
mcp__granola__get_meetings               # Search content: ID, title, date, attendees, private/enhanced notes
mcp__granola__get_meeting_transcript     # Raw transcript (paid tiers only)
mcp__granola__query_granola_meetings     # Conversational queries about meetings
```

Workflow: Use `list_meetings` to find client meeting by title/attendee, then `get_meetings` for notes, `get_meeting_transcript` for verbatim quotes.
Always fetch meeting context for terminology, stakeholders, pain points.

### Step 2: Determine POC Concept

Extract structured data per [references/schemas.md](references/schemas.md).

- **Meeting-driven**: Extract idea from transcript
- **Ideation**: Present 3 concepts (safe, creative, ambitious) - wait for selection
- **Direct idea**: Parse input, enrich with meeting context

Output: title, type, problem, solution, key features.

### Step 3: Research (parallel with Step 4)

- Persona: role, context, tech savviness
- JTBD: main job, related jobs, emotional job
- Pains/Gains: frustrations → desired outcomes
- Competitive landscape: WebSearch existing solutions

### Step 4: Fetch Branding

```
WebFetch url="<client_website>" prompt="Extract brand colors (hex), fonts, visual aesthetic"
```

See [references/schemas.md](references/schemas.md) for fallback values if unreachable.

### Step 5: Generate POC

Invoke `frontend-design` skill with concept, branding, research. POC types:

| Type | Elements |
|------|----------|
| `prototype` | React + Tailwind, mock data, interactions |
| `dashboard` | Charts (recharts), metrics, tables |
| `workflow` | Step-by-step flow, progress states |
| `landing-page` | Hero, features, CTA |
| `form` | Multi-step, validation |

### Step 6: Create Project

```bash
$POC_SKILL_DIR/scripts/scaffold.sh <client-slug> <concept-name>-<YYYY-MM-DD>
```

Customize per [references/templates.md](references/templates.md):
- `app/globals.css` - brand colors
- `app/layout.tsx` - fonts, metadata
- `app/page.tsx` - generated component

Add analytics: `trackEvent()` for `cta_click`, `form_submit`, `feature_use`.

**If backend needed**: See [references/supabase.md](references/supabase.md)
**If LLM needed**: See [references/openrouter.md](references/openrouter.md)

### Step 6b: Initialize Git

```bash
$POC_SKILL_DIR/scripts/init-git.sh $POC_ROOT/<client-slug>/<project-name> <client-slug> "<title>" <type> "<feature1>" "<feature2>"
```

### Step 7: Deploy

```bash
$POC_SKILL_DIR/scripts/deploy.sh $POC_ROOT/<client-slug>/<project-name>
```

Outputs URL: `https://<client-slug>-<id>.$POC_ALIAS_DOMAIN`

### Step 8: Verify & Iterate

Max 3 iterations. Check: loads, branding, content, mobile, analytics.

After fixes:
```bash
git add -A
git commit -m "fix(<client>): <description>"
```

### Step 9: Summary

Output: client, type, title, features, live URL, analytics URL, file path.

Draft client message per [references/message-examples.md](references/message-examples.md).

## Error Handling

See [references/error-handling.md](references/error-handling.md).

## Examples

```bash
/poc                    # Extract idea from recent meeting
/poc acme               # Search Acme meeting, extract idea
/poc ideas              # 3 ideas from recent meeting
/poc acme brainstorm    # 3 ideas from Acme meeting
/poc acme Innovation Radar - market intelligence dashboard
```
