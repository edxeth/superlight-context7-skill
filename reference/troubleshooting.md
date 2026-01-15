# Context7 Troubleshooting & Configuration

## Error Handling

| Error | Cause | Action |
|-------|-------|--------|
| No results | Library not indexed | Inform user: "Context7 has no docs for [X]. Proceed with general knowledge?" |
| 429 Too Many Requests | Rate limit exceeded | Wait 30s and retry, or proceed with caution |
| 5xx Server Error | Context7 service issue | Fall back to training data, note uncertainty |
| Empty response | Query too broad or library misconfigured | Refine query with more specific terms |

## Environment Configuration

```bash
# Optional: API key for higher rate limits
export CONTEXT7_API_KEY="ctx7sk_..."

# Get a key at: https://context7.com/dashboard
```

## Common Issues

### Library Disambiguation

When search returns multiple similar libraries (e.g., `react`, `react-native`, `preact`):
1. Present top 3-5 candidates to user
2. Ask which library they meant
3. Do NOT auto-select unless exact match

### Query Specificity

Poor queries return generic docs. Always prefer specific queries:

| Bad Query | Good Query |
|-----------|------------|
| "react hooks" | "useState hook array destructuring pattern" |
| "next.js routing" | "next.js 15 app router middleware redirect" |
| "prisma" | "prisma findMany with nested relation filters" |

### Version-Specific Lookups

Append version to libraryId when available:
```bash
# Generic (latest)
scripts/context7.sh docs "/vercel/next.js" "middleware"

# Version-specific
scripts/context7.sh docs "/vercel/next.js/v15.1.8" "middleware"
```

## Script Timeouts

The script uses a 30-second timeout. For slow networks:
```bash
# Increase timeout via curl (edit script if needed)
curl --max-time 60 ...
```
