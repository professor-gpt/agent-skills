# Project Name

> One-sentence tagline that describes what this does and for whom.

[![CI](https://github.com/org/repo/actions/workflows/ci.yml/badge.svg)](https://github.com/org/repo/actions/workflows/ci.yml)
[![npm version](https://badge.fury.io/js/package-name.svg)](https://badge.fury.io/js/package-name)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## What It Does

<!-- 2–4 sentences. Focus on the user benefit, not the technology.
     Answer: what problem does this solve, and why should I use this instead of alternatives? -->

**Project Name** lets you [primary action] without [pain point]. Unlike [alternative], it [key differentiator].

```bash
# The simplest possible demo — copy-paste and it works
npx project-name "hello world"
```

---

## Features

- **Feature 1** — Brief explanation of the benefit (not just the capability)
- **Feature 2** — Brief explanation
- **Feature 3** — Brief explanation
- **Feature 4** — Brief explanation

---

## Installation

### Prerequisites

- Node.js ≥ 18.0
- npm ≥ 9.0 (or yarn ≥ 1.22, pnpm ≥ 8)

### Install

```bash
npm install project-name
```

Or with yarn:

```bash
yarn add project-name
```

---

## Quick Start

<!-- The fastest path from zero to working. Should take < 5 minutes.
     Every command must work exactly as written. -->

### Step 1 — Initialize

```bash
npx project-name init
```

This creates a `project-name.config.ts` file in your project root.

### Step 2 — Configure

```typescript
// project-name.config.ts
import { defineConfig } from 'project-name'

export default defineConfig({
  apiKey: process.env.API_KEY,   // Required
  outputDir: './output',          // Optional, default: ./dist
})
```

### Step 3 — Run

```bash
npx project-name run
```

That's it. Output is in `./output/`.

---

## Usage

### Basic Example

```typescript
import { Client } from 'project-name'

const client = new Client({ apiKey: process.env.API_KEY })

const result = await client.process({
  input: 'your input here',
  options: {
    format: 'json',
    verbose: false,
  }
})

console.log(result.output)
```

### Advanced: Custom Configuration

```typescript
const client = new Client({
  apiKey: process.env.API_KEY,
  timeout: 30_000,
  retries: 3,
  onProgress: (pct) => console.log(`${pct}% complete`),
})
```

### CLI Reference

```
Usage: project-name <command> [options]

Commands:
  init          Initialize configuration file
  run [input]   Process input (reads stdin if input omitted)
  validate      Validate your configuration

Options:
  -c, --config   Path to config file     [default: project-name.config.ts]
  -o, --output   Output directory        [default: ./output]
  -v, --verbose  Enable verbose logging
  -h, --help     Show help
  -V, --version  Show version number
```

---

## Configuration Reference

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `apiKey` | `string` | ✅ | — | Your API key |
| `outputDir` | `string` | ❌ | `./output` | Where to write results |
| `timeout` | `number` | ❌ | `10000` | Request timeout in ms |
| `retries` | `number` | ❌ | `2` | Number of retry attempts |
| `verbose` | `boolean` | ❌ | `false` | Enable debug logging |

---

## API Reference

### `Client`

#### Constructor

```typescript
new Client(options: ClientOptions): Client
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options.apiKey` | `string` | Required. API key for authentication. |
| `options.timeout` | `number` | Optional. Request timeout in milliseconds. |

#### `client.process(input)`

```typescript
client.process(input: ProcessInput): Promise<ProcessResult>
```

**Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `input.data` | `string` | The data to process. |
| `input.format` | `'json' \| 'text'` | Output format. Default: `'text'` |

**Returns** `Promise<ProcessResult>`

| Field | Type | Description |
|-------|------|-------------|
| `result.output` | `string` | Processed output |
| `result.metadata` | `object` | Processing metadata |
| `result.duration` | `number` | Processing time in ms |

**Throws**

- `AuthError` — Invalid or expired API key
- `ValidationError` — Invalid input format
- `TimeoutError` — Request exceeded timeout

---

## Error Handling

```typescript
import { Client, AuthError, ValidationError } from 'project-name'

try {
  const result = await client.process({ data: input })
} catch (error) {
  if (error instanceof AuthError) {
    console.error('Invalid API key. Check your environment variable.')
  } else if (error instanceof ValidationError) {
    console.error('Invalid input:', error.message)
    console.error('Fields:', error.fields)   // which fields failed validation
  } else {
    throw error  // Re-throw unexpected errors
  }
}
```

---

## Recipes

### Process Multiple Files

```typescript
import { readdir, readFile } from 'fs/promises'
import { Client } from 'project-name'

const client = new Client({ apiKey: process.env.API_KEY })
const files = await readdir('./input', { withFileTypes: true })

const results = await Promise.all(
  files
    .filter(f => f.isFile() && f.name.endsWith('.txt'))
    .map(async (f) => {
      const content = await readFile(`./input/${f.name}`, 'utf8')
      return client.process({ data: content })
    })
)
```

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development setup, coding conventions, and PR guidelines.

```bash
# Development setup
git clone https://github.com/org/project-name
cd project-name
npm install
npm test
```

---

## License

[MIT](./LICENSE) — © 2026 Your Name
