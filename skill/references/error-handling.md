# Error Handling

| Error | Response |
|-------|----------|
| `git` not found | Stop. See [prerequisites.md](prerequisites.md) |
| `brew` not found | Stop. See [prerequisites.md](prerequisites.md) |
| `bun` not found | Stop. See [prerequisites.md](prerequisites.md) |
| `vercel` not found | Stop. See [prerequisites.md](prerequisites.md) |
| `jq` not found | Stop. See [prerequisites.md](prerequisites.md) |
| `supabase` not found | Warn (optional). Install if POC needs backend |
| Granola MCP unavailable | Stop. Run `/mcp` to authenticate via browser |
| Granola MCP auth expired | Run `/mcp`, select Granola, re-authenticate |
| `frontend-design` skill missing | Stop. Required for UI generation |
| No meetings found (meeting-driven) | Try `/poc <client name>` or `/poc <topic>` |
| No meetings found (direct idea) | Proceed without meeting context |
| Website unreachable | Use fallback branding (see [schemas.md](schemas.md)) |
| Deploy fails | Run `bun dev` locally to debug |
| Alias fails | Use vercel.app URL instead |
