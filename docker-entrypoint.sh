#!/bin/bash
set -e

# ── 1. Start CloakBrowser (CDP backend) ──
CLOAK_ARGS=()
[ "${HEADLESS}" != "false" ] && CLOAK_ARGS+=(--headless=true)
[ "${HEADLESS}" = "false" ] && CLOAK_ARGS+=(--headless=false)
[ -n "${PROXY_SERVER}" ] && CLOAK_ARGS+=(--proxy-server="${PROXY_SERVER}")

echo "🦊 Starting CloakBrowser CDP on ${CDP_HOST}:${CDP_PORT}..."
cloakserve --host="${CDP_HOST}" --remote-debugging-port="${CDP_PORT}" "${CLOAK_ARGS[@]}" &
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
echo "🔧 Starting @playwright/mcp on ${MCP_HOST}:${MCP_PORT}..."

MCP_ARGS=(
  --port "${MCP_PORT}"
  --host "${MCP_HOST}"
  --allowed-hosts "*"
)

# Optional flags — passed through env vars (set the env var to enable)
[ -n "${MCP_ISOLATED}" ] && MCP_ARGS+=(--isolated)
[ -n "${STORAGE_STATE}" ] && MCP_ARGS+=(--storage-state="${STORAGE_STATE}")
[ -n "${USER_DATA_DIR}" ] && MCP_ARGS+=(--user-data-dir="${USER_DATA_DIR}")
[ -n "${VIEWPORT_SIZE}" ] && MCP_ARGS+=(--viewport-size="${VIEWPORT_SIZE}")
[ -n "${DEVICE}" ] && MCP_ARGS+=(--device="${DEVICE}")
[ -n "${USER_AGENT}" ] && MCP_ARGS+=(--user-agent="${USER_AGENT}")
[ -n "${CAPS}" ] && MCP_ARGS+=(--caps="${CAPS}")
[ -n "${PROXY_BYPASS}" ] && MCP_ARGS+=(--proxy-bypass="${PROXY_BYPASS}")
[ -n "${TIMEOUT_ACTION}" ] && MCP_ARGS+=(--timeout-action="${TIMEOUT_ACTION}")
[ -n "${TIMEOUT_NAVIGATION}" ] && MCP_ARGS+=(--timeout-navigation="${TIMEOUT_NAVIGATION}")
[ -n "${CONSOLE_LEVEL}" ] && MCP_ARGS+=(--console-level="${CONSOLE_LEVEL}")
[ "${IGNORE_HTTPS_ERRORS}" = "true" ] && MCP_ARGS+=(--ignore-https-errors)
[ "${BLOCK_SERVICE_WORKERS}" = "true" ] && MCP_ARGS+=(--block-service-workers)
[ -n "${BLOCKED_ORIGINS}" ] && MCP_ARGS+=(--blocked-origins="${BLOCKED_ORIGINS}")
[ -n "${ALLOWED_ORIGINS}" ] && MCP_ARGS+=(--allowed-origins="${ALLOWED_ORIGINS}")
[ -n "${GRANT_PERMISSIONS}" ] && MCP_ARGS+=(--grant-permissions="${GRANT_PERMISSIONS}")
[ "${SAVE_SESSION}" = "true" ] && MCP_ARGS+=(--save-session)
[ -n "${OUTPUT_DIR}" ] && MCP_ARGS+=(--output-dir="${OUTPUT_DIR}")
[ -n "${INIT_SCRIPT}" ] && MCP_ARGS+=(--init-script="${INIT_SCRIPT}")
[ -n "${INIT_PAGE}" ] && MCP_ARGS+=(--init-page="${INIT_PAGE}")
[ -n "${SECRETS_FILE}" ] && MCP_ARGS+=(--secrets="${SECRETS_FILE}")

# Additional @playwright/mcp flags
[ "${ALLOW_UNRESTRICTED_FILE_ACCESS}" = "true" ] && MCP_ARGS+=(--allow-unrestricted-file-access)
[ -n "${BROWSER}" ] && MCP_ARGS+=(--browser="${BROWSER}")
[ -n "${CDP_HEADERS}" ] && MCP_ARGS+=(--cdp-header="${CDP_HEADERS}")
[ -n "${CDP_TIMEOUT}" ] && MCP_ARGS+=(--cdp-timeout="${CDP_TIMEOUT}")
[ -n "${CODEGEN}" ] && MCP_ARGS+=(--codegen="${CODEGEN}")
[ -n "${MCP_CONFIG}" ] && MCP_ARGS+=(--config="${MCP_CONFIG}")
[ -n "${EXECUTABLE_PATH}" ] && MCP_ARGS+=(--executable-path="${EXECUTABLE_PATH}")
[ "${EXTENSION}" = "true" ] && MCP_ARGS+=(--extension)
[ "${MCP_HEADLESS}" = "true" ] && MCP_ARGS+=(--headless)
[ -n "${IMAGE_RESPONSES}" ] && MCP_ARGS+=(--image-responses="${IMAGE_RESPONSES}")
[ "${NO_SANDBOX}" = "true" ] && MCP_ARGS+=(--no-sandbox)
[ -n "${OUTPUT_MODE}" ] && MCP_ARGS+=(--output-mode="${OUTPUT_MODE}")
[ -n "${MCP_PROXY_SERVER}" ] && MCP_ARGS+=(--proxy-server="${MCP_PROXY_SERVER}")
[ "${SANDBOX}" = "true" ] && MCP_ARGS+=(--sandbox)
[ "${SHARED_BROWSER_CONTEXT}" = "true" ] && MCP_ARGS+=(--shared-browser-context)
[ -n "${SNAPSHOT_MODE}" ] && MCP_ARGS+=(--snapshot-mode="${SNAPSHOT_MODE}")
[ -n "${TEST_ID_ATTRIBUTE}" ] && MCP_ARGS+=(--test-id-attribute="${TEST_ID_ATTRIBUTE}")

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
