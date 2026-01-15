# Superlight Context7 Skill

Fetch real-time library documentation via the Context7 v2 REST API. A superlight agent skill for AI coding assistants — minimal tokens, maximum docs. Supports multiple API keys with round-robin rotation for higher rate limits.

## Features

- **Real-time docs** — Fetches current documentation from Context7's indexed library database
- **Version-aware** — Query specific versions or get latest API references
- **Token-efficient** — Minimal context overhead with progressive disclosure
- **Agent-agnostic** — Works with Claude Code, Cursor, and other skill-compatible agents
- **No MCP required** — Direct REST API integration via bash script
- **Multi-key rotation** — Distribute requests across multiple API keys with automatic 429 failover

## Why Use This Over Context7 MCP?

| Aspect | MCP Server | This Skill |
|--------|------------|------------|
| Context cost | ~500-2000 tokens always | **~60 tokens always** + ~340 on-demand |
| Tool schemas | Always in context | None |
| Setup | Requires MCP configuration | Drop-in skill directory |
| Dependencies | Node.js runtime | bash, curl, jq (Linux/macOS) |

Best for: Users who need library docs on-demand without persistent context overhead.

## Token Budget

Uses Claude's [progressive disclosure](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills) architecture:

| Level | When Loaded | Content | Tokens |
|-------|-------------|---------|--------|
| **Metadata** | Always (startup) | Skill description | ~60 |
| **Instructions** | When triggered | SKILL.md protocol | ~340 |
| **Resources** | As needed | troubleshooting.md | ~280 |

## Installation

### Claude Code

```bash
# Clone to skills directory
git clone https://github.com/edxeth/superlight-context7-skill.git ~/.claude/skills/context7
```

### Manual Installation

Download and extract to your agent's skills directory:

```
~/.claude/skills/context7/
├── SKILL.md
├── reference/
│   └── troubleshooting.md
└── scripts/
    └── context7.sh
```

## Usage

The skill triggers automatically when working with external packages:

```
"How do I use React Query's optimistic updates?"
"Debug this Next.js middleware error"
"What's the Prisma syntax for nested filters?"
"Check if this API is deprecated in v5"
```

### Manual Invocation

```bash
# Search for a library
./scripts/context7.sh search "tanstack-query" "mutations"

# Fetch documentation
./scripts/context7.sh docs "/tanstack/query" "useMutation optimistic update"
```

## API Endpoints

Uses Context7 v2 REST API:

| Endpoint | Purpose |
|----------|---------|
| `GET /api/v2/libs/search` | Find library IDs by name |
| `GET /api/v2/context` | Fetch documentation context |

## Configuration

An API key is optional but recommended for higher rate limits.

```bash
# Single API key
export CONTEXT7_API_KEY="ctx7sk_..."

# Multiple API keys for load distribution
export CONTEXT7_API_KEY="ctx7sk_key1,ctx7sk_key2,ctx7sk_key3"
```

When multiple keys are provided (comma-separated), the script rotates through them in round-robin order, ensuring even distribution of requests. If a key hits rate limits (429), the script automatically fails over to the next key and retries, only failing after all keys are exhausted across multiple retry rounds.

Get an API key at [context7.com/dashboard](https://context7.com/dashboard).

## Requirements

- **Platforms**: Linux, macOS
- **Dependencies**: bash, curl, jq

## Skill Metadata

```yaml
name: context7
description: Fetches up-to-date third-party library documentation via the Context7 v2 REST API. Use when working with external packages and needing current API references, code examples, migration guides, or resolving package errors (stack traces, version mismatches, deprecated methods).
allowed-tools: [bash]
user-invocable: true
```

## License

MIT License — See [LICENSE](LICENSE) for details.

## Credits

- [Context7](https://context7.com/) API by [Upstash](https://upstash.com/)
- Original skill by [Netresearch GmbH & Co. KG](https://github.com/netresearch/context7-skill)
