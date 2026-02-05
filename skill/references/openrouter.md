# OpenRouter Setup for POCs

## When to Use

| POC Feature | Needs LLM? | Example |
|-------------|------------|---------|
| Static content | No | Landing pages, dashboards with mock data |
| AI chat/assistant | Yes | Chatbots, Q&A interfaces |
| Content generation | Yes | Writing tools, summarizers |
| Smart search | Yes | Semantic search, recommendations |
| Analysis tools | Yes | Document analysis, insights |

## API Key

**Ask the user for their OpenRouter API key** before proceeding:

> "This POC needs an LLM. Please provide your OpenRouter API key from https://openrouter.ai/keys"

Add to `.env.local`:

```bash
OPENROUTER_API_KEY=sk-or-v1-...
```

Add to `.gitignore` (already included in template):

```
.env.local
```

## Dependencies

Add to package.json:

```json
{
  "dependencies": {
    "ai": "^4.0.0",
    "@ai-sdk/openai": "^1.0.0"
  }
}
```

## Provider Setup

Create `lib/ai.ts`:

```ts
import { createOpenAI } from "@ai-sdk/openai"

export const openrouter = createOpenAI({
  baseURL: "https://openrouter.ai/api/v1",
  apiKey: process.env.OPENROUTER_API_KEY,
})

// Recommended models for POCs (fast, cheap, good)
export const models = {
  fast: openrouter("anthropic/claude-3-5-haiku"),      // Quick responses
  balanced: openrouter("anthropic/claude-3-5-sonnet"), // Good all-rounder
  smart: openrouter("anthropic/claude-sonnet-4"),      // Complex tasks
} as const
```

## Common Patterns

### Chat Interface (Streaming)

Server action in `app/actions.ts`:

```ts
"use server"

import { streamText } from "ai"
import { createStreamableValue } from "ai/rsc"
import { models } from "@/lib/ai"

export async function chat(messages: { role: string; content: string }[]) {
  const stream = createStreamableValue("")

  ;(async () => {
    const { textStream } = streamText({
      model: models.balanced,
      messages,
    })

    for await (const delta of textStream) {
      stream.update(delta)
    }

    stream.done()
  })()

  return { output: stream.value }
}
```

Client component:

```tsx
"use client"

import { useState } from "react"
import { useChat } from "ai/react"
import { trackEvent } from "@/lib/analytics"

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat({
    onFinish: () => trackEvent("feature_use", { name: "chat", value: "complete" }),
  })

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id}>{m.role}: {m.content}</div>
      ))}
      <form onSubmit={handleSubmit}>
        <input value={input} onChange={handleInputChange} />
        <button type="submit">Send</button>
      </form>
    </div>
  )
}
```

### Simple Generation (Non-streaming)

```ts
import { generateText } from "ai"
import { models } from "@/lib/ai"

const { text } = await generateText({
  model: models.fast,
  prompt: "Summarize this document: ...",
})
```

### Structured Output

```ts
import { generateObject } from "ai"
import { z } from "zod"
import { models } from "@/lib/ai"

const { object } = await generateObject({
  model: models.balanced,
  schema: z.object({
    sentiment: z.enum(["positive", "negative", "neutral"]),
    summary: z.string(),
    keywords: z.array(z.string()),
  }),
  prompt: "Analyze this feedback: ...",
})
```

## API Route (Alternative)

If not using server actions, create `app/api/chat/route.ts`:

```ts
import { streamText } from "ai"
import { models } from "@/lib/ai"

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: models.balanced,
    messages,
  })

  return result.toDataStreamResponse()
}
```

## Cost Awareness

OpenRouter charges per token. For POCs:
- Use `models.fast` (Haiku) for simple tasks
- Use `models.balanced` (Sonnet) for demos
- Add rate limiting if POC is public
- Monitor usage at https://openrouter.ai/activity
