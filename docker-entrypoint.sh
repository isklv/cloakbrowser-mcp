#!/bin/bash
set -e

# ── 1. Start CloakBrowser (CDP backend) ──
CLOAK_ARGS=()
[ "${HEADLESS}" != "false" ] && CLOAK_ARGS+=(--headless=true)
[ "${HEADLESS}" = "false" ] && CLOAK_ARGS+=(--headless=false)
[ -n "${PROXY_SERVER}" ] && CLOAK_ARGS+=(--proxy-server="${PROXY_SERVER}")

echo "🦊 Starting CloakBrowser CDP on :${CDP_PORT}..."
cloakserve --remote-debugging-port="${CDP_PORT}" "${CLOAK_ARGS[@]}" &
CLOAK_PID=$!
echo "   PID: ${CLOAK_PID}"

# Wait for CDP readiness
echo "⏳ Waiting for CloakBrowser..."
for i in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:${CDP_PORT}/json/version" >/dev/null 2>&1; then
    echo "✅ CloakBrowser ready"
    break
  fi
  [ "$i" -eq 30 ] && { echo "❌ CloakBrowser failed to start"; exit 1; }
  sleep 1
done

# ── 2. Start @playwright/mcp (MCP frontend) ──
echo "🔧 Starting @playwright/mcp on :${MCP_PORT}..."

MCP_ARGS=(--port "${MCP_PORT}")
[ "${ISOLATED}" = "true" ] && MCP_ARGS+=(--isolated)
[ -n "${STORAGE_STATE}" ] && MCP_ARGS+=(--storage-state="${STORAGE_STATE}")

# Cleanup on exit
cleanup() {
  echo "🛑 Shutting down..."
  kill "${CLOAK_PID}" 2>/dev/null
  wait "${CLOAK_PID}" 2>/dev/null
  echo "✅ Done"
}
trap cleanup EXIT INT TERM

# Connect MCP to CloakBrowser via CDP
exec npx @playwright/mcp@latest \
  --cdp-endpoint="http://127.0.0.1:${CDP_PORT}" \
  "${MCP_ARGS[@]}"
