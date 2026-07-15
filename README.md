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
| Context cost | **~1,700 tokens always**¹ | **~63 tokens always** + ~424 on-demand |
| Tool schemas | Always in context | None (progressive disclosure) |
| Setup | Requires MCP configuration | Drop-in skill directory |
| Dependencies | Node.js runtime | bash, curl, jq (Linux/macOS) |

¹ *Measured Nov 2025 via `/context` command. [Source](https://github.com/anthropics/claude-code/issues/11085#issuecomment-3508840896)*

Best for: Users who need library docs on-demand without persistent context overhead.

## Token Budget

Uses Claude's [progressive disclosure](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills) architecture:

| Level | When Loaded | Content | Tokens |
|-------|-------------|---------|--------|
| **Metadata** | Always (startup) | Skill description | ~63 |
| **Instructions** | When triggered | SKILL.md protocol | ~424 |
| **Resources** | As needed | troubleshooting.md | ~521 |

*Token counts measured with [claudetokenizer.com](https://www.claudetokenizer.com/) (Claude Sonnet 4.5)*

## Installation

### Quick Install (Recommended)

```bash
npx skills add edxeth/superlight-context7-skill
```

The installer will prompt you to select which agents to install to (Claude Code, Cursor, OpenCode, Codex, Antigravity, etc.).

### Manual Installation

Clone the repository, then copy the bundled skill directory into your agent's skills directory:

```bash
git clone https://github.com/edxeth/superlight-context7-skill.git /tmp/superlight-context7-skill

# Claude Code
mkdir -p ~/.claude/skills/context7
cp -R /tmp/superlight-context7-skill/context7/. ~/.claude/skills/context7/

# OpenCode
mkdir -p ~/.opencode/skill/context7
cp -R /tmp/superlight-context7-skill/context7/. ~/.opencode/skill/context7/
```

**Repository structure:**

```
superlight-context7-skill/
└── context7/
    ├── SKILL.md
    ├── reference/
    │   └── troubleshooting.md
    └── scripts/
        └── context7.sh
```

Keeping `SKILL.md` inside the skill directory ensures `npx skills add` installs its scripts and references together.

If you previously cloned the repository directly into an agent's `context7` directory, run the same `cp -R source/context7/. destination/context7/` command after pulling this update. The trailing `/.` copies the bundle contents into the existing directory instead of creating a broken `context7/context7/` nesting.

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
# From the repository root
./context7/scripts/context7.sh search "tanstack-query" "mutations"
./context7/scripts/context7.sh docs "/tanstack/query" "useMutation optimistic update"

# From an installed context7 skill directory
./scripts/context7.sh search "tanstack-query" "mutations"
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
