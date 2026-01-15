#!/bin/bash
# Context7 v2 REST API Client
# Endpoints: /api/v2/libs/search, /api/v2/context
# Docs: https://context7.com/docs/api-guide.md

set -euo pipefail

readonly API_BASE="https://context7.com/api/v2"
readonly API_KEY="${CONTEXT7_API_KEY:-}"

# URL-encode a string (POSIX-compatible)
urlencode() {
    local string="$1"
    python3 -c "import urllib.parse; print(urllib.parse.quote('''$string''', safe=''))" 2>/dev/null \
        || printf '%s' "$string" | jq -sRr @uri 2>/dev/null \
        || printf '%s' "$string"
}

# Build curl command with optional auth
do_request() {
    local url="$1"
    local -a curl_args=(-s -f --max-time 30)
    
    if [[ -n "$API_KEY" ]]; then
        curl_args+=(-H "Authorization: Bearer $API_KEY")
    fi
    curl_args+=(-H "X-Context7-Source: claude-skill")
    
    curl "${curl_args[@]}" "$url"
}

# Search for library ID
# API: GET /api/v2/libs/search?libraryName=<name>&query=<intent>
cmd_search() {
    local library="${1:-}"
    local intent="${2:-}"
    
    if [[ -z "$library" ]]; then
        echo "Usage: context7.sh search <library> [intent]"
        echo "Example: context7.sh search react \"hooks state management\""
        exit 1
    fi
    
    local lib_encoded intent_encoded url
    lib_encoded=$(urlencode "$library")
    intent_encoded=$(urlencode "$intent")
    
    url="${API_BASE}/libs/search?libraryName=${lib_encoded}"
    [[ -n "$intent" ]] && url="${url}&query=${intent_encoded}"
    
    local response
    if ! response=$(do_request "$url"); then
        echo "ERROR: Search failed. Check network or API key." >&2
        exit 1
    fi
    
    # Parse and output minimal info for token efficiency
    echo "$response" | jq -r '
        if .results and (.results | length > 0) then
            "\(.results | length) results:" +
            (.results[:5] | map("\n  \(.id)  [\(.title // .name // "?")]") | join(""))
        elif .error then
            "ERROR: " + .error
        else
            "No results"
        end
    ' 2>/dev/null || echo "$response"
}

# Fetch documentation context
# API: GET /api/v2/context?libraryId=<id>&query=<question>
cmd_docs() {
    local library_id="${1:-}"
    local query="${2:-}"
    
    if [[ -z "$library_id" || -z "$query" ]]; then
        echo "Usage: context7.sh docs <library-id> <query>"
        echo "Example: context7.sh docs /vercel/next.js \"middleware authentication\""
        exit 1
    fi
    
    local id_encoded query_encoded url
    id_encoded=$(urlencode "$library_id")
    query_encoded=$(urlencode "$query")
    
    url="${API_BASE}/context?libraryId=${id_encoded}&query=${query_encoded}"
    
    local response
    if ! response=$(do_request "$url"); then
        echo "ERROR: Failed to fetch docs for $library_id" >&2
        exit 1
    fi
    
    # Return raw text (Context7 returns optimized snippets)
    echo "$response"
}

# Main dispatch
case "${1:-}" in
    search)
        shift
        cmd_search "$@"
        ;;
    docs)
        shift
        cmd_docs "$@"
        ;;
    -h|--help|help)
        cat <<'EOF'
Context7 Documentation Lookup

Usage:
  context7.sh search <library> [intent]    Find library ID
  context7.sh docs <library-id> <query>    Fetch documentation

Examples:
  context7.sh search react "hooks"
  context7.sh search "next.js" "app router middleware"
  context7.sh docs /vercel/next.js "middleware redirect pattern"
  context7.sh docs /tanstack/query "useMutation v5 optimistic"

Environment:
  CONTEXT7_API_KEY    Optional API key for higher rate limits
                      Get one at: https://context7.com/dashboard
EOF
        ;;
    *)
        echo "Usage: context7.sh {search|docs} [args...]"
        echo "Run 'context7.sh --help' for examples"
        exit 1
        ;;
esac
