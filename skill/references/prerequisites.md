# Prerequisites

## Required CLI Tools

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| `git` | Version control | `xcode-select --install` or `brew install git` |
| `brew` | Package manager | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| `bun` | JS runtime & package manager | `curl -fsSL https://bun.sh/install \| bash` |
| `vercel` | Deployment | `bun add -g vercel` then `vercel login` |
| `jq` | JSON parsing | `brew install jq` |

## Optional

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| `supabase` | Backend (auth, data) | `brew install supabase/tap/supabase` |

## Required Integrations

| Integration | Purpose | Setup |
|-------------|---------|-------|
| Granola MCP | Meeting transcripts | Run `/mcp` to authenticate |
| `frontend-design` skill | UI generation | Must be installed |

## Verification Commands

Run each separately (not chained with `&&`):

```bash
command -v git
command -v brew
command -v bun
command -v vercel
command -v jq
command -v supabase
```

**Test Granola MCP auth** (must return meetings, not auth error):
```
mcp__granola__list_meetings
```

If auth fails: Run `/mcp`, select Granola, complete browser OAuth. Auth expires between sessions - re-run `/mcp` at start of each session if needed.
