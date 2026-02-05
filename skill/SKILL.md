---
name: poc
description: >-
  Generate a proof-of-concept from a client call transcript via Granola MCP.
  Use when the user says "/poc", "build poc from call", "create demo for client",
  or wants to turn a meeting into a working prototype.
  Modes: (1) "/poc" - list recent meetings and pick one,
  (2) "/poc latest" - use most recent meeting,
  (3) "/poc [client]" - search for client meeting,
  (4) "/poc ideas" or "/poc [client] brainstorm" - get 3 POC ideas first,
  (5) "/poc [client] [idea description]" - build specific idea with meeting context.
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

**First-use setup** (only needed once):

1. Check `frontend-design` plugin:
   ```bash
   claude plugin list | grep frontend-design
   ```
   If missing: `claude plugin install frontend-design@claude-plugins-official`

2. Check Granola MCP configured:
   ```bash
   cat ~/.claude.json | jq '.mcpServers.granola'
   ```
   If missing: `claude mcp add granola --transport http https://mcp.granola.ai/mcp`

**Every run:**

1. Load config:
   ```bash
   source <skill-dir>/scripts/load-config.sh
   ```
   Exports: `POC_SKILL_DIR`, `POC_ROOT`, `POC_VERCEL_SCOPE`, `POC_ALIAS_DOMAIN`.

2. Fetch meetings list (doubles as auth check):
   ```
   mcp__granola__list_meetings
   ```
   If auth error: tell user to run `/mcp`, select Granola, authenticate in browser.

3. Parse input to determine mode:

| Input | Mode | Meeting Selection |
|-------|------|-------------------|
| (empty) | Interactive | Show meeting list, ask user to pick |
| `latest` | Auto-select | Use most recent meeting |
| `<client>` | Search | Filter meetings by client name |
| `ideas` or `<client> brainstorm` | Ideation | Present 3 POC concepts first |
| `<client> <description>` | Direct idea | Use specific idea + meeting context |

### Step 1: Get Meeting

Based on mode from Step 0:

**Interactive (`/poc`):**
- Display meetings from `list_meetings` as numbered list (title, date, attendees)
- Ask user: "Which meeting?" (or use AskUserQuestion with options)
- User selects by number or name

**Auto-select (`/poc latest`):**
- Use first/most recent meeting from list

**Search (`/poc <client>`):**
- Filter meeting list by client name in title/attendees
- If single match: use it. If multiple: show filtered list and ask.

Then fetch meeting details:
```
mcp__granola__get_meetings               # Notes, attendees, enhanced content
mcp__granola__get_meeting_transcript     # Raw transcript (paid tiers only)
```

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
/poc                    # List recent meetings, pick one interactively
/poc latest             # Use most recent meeting automatically
/poc acme               # Search for Acme meeting
/poc ideas              # 3 POC ideas from selected meeting
/poc acme brainstorm    # 3 ideas from Acme meeting
/poc acme Innovation Radar - market intelligence dashboard
```
