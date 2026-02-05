# Supabase Setup for POCs

## When to Use

| POC Type | Needs Supabase? | Use Case |
|----------|-----------------|----------|
| Landing page | No | Static content |
| Dashboard | Maybe | If showing real/persisted data |
| Prototype | Maybe | If auth or data persistence needed |
| Workflow | Yes | Multi-step flows often need state |
| Form | Yes | Form submissions need storage |

## Quick Setup

```bash
cd <poc-directory>
supabase init
supabase start
```

This starts local Supabase with:
- Postgres on `localhost:54322`
- Studio on `localhost:54323`
- API on `localhost:54321`

## Environment Variables

Add to `.env.local`:

```bash
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=<from supabase start output>
```

## Dependencies

Add to package.json:

```json
{
  "dependencies": {
    "@supabase/supabase-js": "^2.47.0",
    "@supabase/ssr": "^0.5.0"
  }
}
```

## Client Setup

Create `lib/supabase.ts`:

```ts
import { createBrowserClient } from "@supabase/ssr"

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

## Common Patterns

### Simple Data Fetch

```ts
const supabase = createClient()
const { data, error } = await supabase
  .from("items")
  .select("*")
  .order("created_at", { ascending: false })
```

### Form Submission

```ts
const supabase = createClient()
const { error } = await supabase
  .from("submissions")
  .insert({ name, email, message })

if (!error) {
  trackEvent("form_submit", { name: "contact", value: "success" })
}
```

### Simple Auth (Magic Link)

```ts
const supabase = createClient()
await supabase.auth.signInWithOtp({ email })
```

## Quick Schema

For POCs, create tables directly in Studio (`localhost:54323`) or via SQL:

```sql
-- Example: Form submissions
create table submissions (
  id uuid default gen_random_uuid() primary key,
  created_at timestamptz default now(),
  name text,
  email text,
  message text
);

-- Enable public insert (for POC only)
alter table submissions enable row level security;
create policy "Anyone can insert" on submissions for insert with check (true);
create policy "Anyone can read" on submissions for select using (true);
```

## Deploy Considerations

For deployed POCs needing Supabase:
1. Create project at [supabase.com](https://supabase.com)
2. Update `.env.local` with production URL/key
3. Run migrations: `supabase db push`

Or keep it simple: use local Supabase for demos, deploy static version for async viewing.
