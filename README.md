# POC Skill for Claude Code

Generate branded proof-of-concepts from Granola meeting transcripts.

## Features

- Extracts POC ideas from client meeting transcripts (via Granola MCP)
- Fetches client branding automatically
- Generates React/Next.js prototypes with Tailwind CSS
- Deploys to Vercel with custom domains
- Tracks engagement with Vercel Analytics

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/s-max/poc-skill/main/install-poc.sh | bash
```

Then in Claude Code:
1. Run `/mcp` and authenticate Granola (required each session)
2. Try `/poc`

## Usage

```bash
/poc                    # Extract idea from most recent meeting
/poc acme               # Search for Acme meeting, extract idea
/poc ideas              # Get 3 POC ideas from recent meeting
/poc acme brainstorm    # Get 3 ideas from Acme meeting
/poc acme Innovation Radar - market intelligence dashboard
```

## Requirements

- [Claude Code](https://claude.ai/code)
- [Granola](https://granola.ai) account (for meeting transcripts)
- [Vercel](https://vercel.com) account (for deployment)
- [Bun](https://bun.sh) runtime

## What Gets Installed

The installer:
1. Extracts skill files to `~/.claude/skills/poc`
2. Installs `frontend-design` plugin (for UI generation)
3. Configures Granola MCP globally
4. Sets up project-level hooks in your POC directory

## License

MIT
