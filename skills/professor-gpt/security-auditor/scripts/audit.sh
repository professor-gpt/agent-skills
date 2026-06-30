#!/usr/bin/env bash
# =============================================================================
# security-audit.sh
# Quick security scan for a web application.
# Runs passive / non-destructive checks only — safe to run against staging.
#
# Usage:
#   ./audit.sh https://staging.example.com
#   ./audit.sh https://staging.example.com --full    # includes dependency scan
#   ./audit.sh https://staging.example.com --json    # JSON output
#
# Requirements: curl, nmap (optional), jq (optional)
# =============================================================================

set -euo pipefail

TARGET="${1:-}"
FULL_SCAN=false
JSON_OUTPUT=false
PASS=0
WARN=0
FAIL=0
RESULTS=()

# ── Argument parsing ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --full) FULL_SCAN=true ;;
    --json) JSON_OUTPUT=true ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <target-url> [--full] [--json]"
  echo "Example: $0 https://staging.example.com"
  exit 1
fi

# Strip trailing slash
TARGET="${TARGET%/}"

# ── Helpers ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
NC='\033[0m'

pass() { echo -e "${GRN}[PASS]${NC} $1"; PASS=$((PASS+1)); RESULTS+=("{\"status\":\"PASS\",\"check\":\"$1\"}"); }
warn() { echo -e "${YEL}[WARN]${NC} $1"; WARN=$((WARN+1)); RESULTS+=("{\"status\":\"WARN\",\"check\":\"$1\"}"); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; FAIL=$((FAIL+1)); RESULTS+=("{\"status\":\"FAIL\",\"check\":\"$1\"}"); }

header_check() {
  local name="$1"
  local header="$2"
  local response_headers="$3"
  if echo "$response_headers" | grep -qi "^${header}:"; then
    pass "Header present: ${header}"
  else
    fail "Header missing: ${header}"
  fi
}

# ── Fetch response headers ────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  Security Audit: $TARGET"
echo "  $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "============================================================"
echo ""

echo ">>> Fetching headers..."
HEADERS=$(curl -sI --max-time 10 --location "$TARGET" 2>/dev/null || echo "")

if [[ -z "$HEADERS" ]]; then
  echo "ERROR: Could not connect to $TARGET"
  exit 1
fi

# ── 1. HTTPS check ────────────────────────────────────────────────────────────
echo ""
echo "--- Transport Security ---"
if echo "$TARGET" | grep -q "^https://"; then
  pass "Target uses HTTPS"
else
  fail "Target does not use HTTPS"
fi

# Check HSTS
if echo "$HEADERS" | grep -qi "strict-transport-security:"; then
  HSTS=$(echo "$HEADERS" | grep -i "strict-transport-security:" | head -1)
  if echo "$HSTS" | grep -qi "max-age="; then
    MAX_AGE=$(echo "$HSTS" | grep -oE 'max-age=[0-9]+' | grep -oE '[0-9]+')
    if [[ "$MAX_AGE" -ge 31536000 ]]; then
      pass "HSTS: max-age=${MAX_AGE} (≥ 1 year)"
    else
      warn "HSTS: max-age=${MAX_AGE} is too short (recommend ≥ 31536000)"
    fi
  fi
else
  fail "HSTS header missing (Strict-Transport-Security)"
fi

# ── 2. Security headers ───────────────────────────────────────────────────────
echo ""
echo "--- HTTP Security Headers ---"

for HEADER in \
  "X-Content-Type-Options" \
  "X-Frame-Options" \
  "Referrer-Policy" \
  "Permissions-Policy"
do
  header_check "$HEADER" "$HEADER" "$HEADERS"
done

# Content-Security-Policy
if echo "$HEADERS" | grep -qi "content-security-policy:"; then
  CSP=$(echo "$HEADERS" | grep -i "content-security-policy:" | head -1)
  if echo "$CSP" | grep -q "unsafe-inline"; then
    warn "CSP contains 'unsafe-inline' — weakens XSS protection"
  elif echo "$CSP" | grep -q "unsafe-eval"; then
    warn "CSP contains 'unsafe-eval' — allows arbitrary JS eval"
  else
    pass "Content-Security-Policy present and does not allow unsafe-inline/eval"
  fi
else
  fail "Content-Security-Policy header missing"
fi

# ── 3. Cookie security ────────────────────────────────────────────────────────
echo ""
echo "--- Cookie Security ---"

COOKIES=$(echo "$HEADERS" | grep -i "set-cookie:" || true)
if [[ -n "$COOKIES" ]]; then
  while IFS= read -r cookie_line; do
    COOKIE_NAME=$(echo "$cookie_line" | grep -oP '(?<=set-cookie: )[^=]+' | head -1 || echo "unknown")
    [[ -z "$COOKIE_NAME" ]] && continue

    echo "$cookie_line" | grep -qi "httponly" && pass "Cookie ${COOKIE_NAME}: HttpOnly set" \
      || fail "Cookie ${COOKIE_NAME}: HttpOnly missing"
    echo "$cookie_line" | grep -qi "; secure" && pass "Cookie ${COOKIE_NAME}: Secure flag set" \
      || fail "Cookie ${COOKIE_NAME}: Secure flag missing"
    echo "$cookie_line" | grep -qi "samesite" && pass "Cookie ${COOKIE_NAME}: SameSite set" \
      || warn "Cookie ${COOKIE_NAME}: SameSite not set (CSRF risk)"
  done <<< "$COOKIES"
else
  echo "  (no Set-Cookie headers in response)"
fi

# ── 4. Information disclosure ─────────────────────────────────────────────────
echo ""
echo "--- Information Disclosure ---"

SERVER=$(echo "$HEADERS" | grep -i "^server:" | head -1 || true)
if [[ -n "$SERVER" ]] && echo "$SERVER" | grep -qE "[0-9]+\.[0-9]+"; then
  warn "Server header reveals version: $SERVER"
elif [[ -n "$SERVER" ]]; then
  warn "Server header present (consider removing): $SERVER"
else
  pass "Server header not present"
fi

X_POWERED=$(echo "$HEADERS" | grep -i "^x-powered-by:" | head -1 || true)
if [[ -n "$X_POWERED" ]]; then
  fail "X-Powered-By header reveals technology: $X_POWERED"
else
  pass "X-Powered-By header not present"
fi

# ── 5. Sensitive path exposure ────────────────────────────────────────────────
echo ""
echo "--- Sensitive Path Exposure ---"

PATHS=(
  "/.env"
  "/.git/config"
  "/wp-admin"
  "/.well-known/security.txt"
  "/api/health"
  "/actuator"
  "/debug"
  "/__admin"
  "/swagger-ui.html"
  "/api-docs"
)

for PATH_CHECK in "${PATHS[@]}"; do
  HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 5 "${TARGET}${PATH_CHECK}" 2>/dev/null || echo "000")
  case "$HTTP_CODE" in
    200)
      case "$PATH_CHECK" in
        "/.env"|"/.git/config")
          fail "CRITICAL — ${PATH_CHECK} is publicly accessible (${HTTP_CODE})" ;;
        "/actuator"|"/debug"|"/__admin")
          fail "Sensitive endpoint exposed: ${PATH_CHECK} (${HTTP_CODE})" ;;
        "/.well-known/security.txt")
          pass "security.txt found (${HTTP_CODE})" ;;
        *)
          warn "${PATH_CHECK} returned ${HTTP_CODE}" ;;
      esac ;;
    301|302|307|308)
      echo "  [REDIR] ${PATH_CHECK} → ${HTTP_CODE}" ;;
    401|403)
      pass "${PATH_CHECK} protected (${HTTP_CODE})" ;;
    404|410)
      pass "${PATH_CHECK} not found (${HTTP_CODE})" ;;
    *)
      echo "  [SKIP] ${PATH_CHECK} → ${HTTP_CODE}" ;;
  esac
done

# ── 6. Dependency scan (optional) ─────────────────────────────────────────────
if $FULL_SCAN; then
  echo ""
  echo "--- Dependency Audit ---"
  if command -v npm &>/dev/null && [[ -f "package.json" ]]; then
    npm audit --audit-level=high --json 2>/dev/null | \
      jq -r '.vulnerabilities | to_entries[] | select(.value.severity == "high" or .value.severity == "critical") | "\(.value.severity | ascii_upcase): \(.key)"' \
      2>/dev/null || true
  elif command -v pip-audit &>/dev/null; then
    pip-audit --format=columns 2>/dev/null || true
  else
    warn "No package manager found for dependency scan (run from project root)"
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  SUMMARY"
echo "============================================================"
echo -e "  ${GRN}PASS${NC}: $PASS"
echo -e "  ${YEL}WARN${NC}: $WARN"
echo -e "  ${RED}FAIL${NC}: $FAIL"
echo ""

if $JSON_OUTPUT; then
  RESULTS_JSON=$(IFS=,; echo "[${RESULTS[*]}]")
  echo "{\"target\":\"$TARGET\",\"pass\":$PASS,\"warn\":$WARN,\"fail\":$FAIL,\"checks\":$RESULTS_JSON}"
fi

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
