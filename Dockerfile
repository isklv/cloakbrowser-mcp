# syntax=docker/dockerfile:1
# CloakBrowser MCP — Stealth Chromium + Playwright MCP Server
# Runs CloakBrowser (CDP backend) + @playwright/mcp (MCP frontend)

FROM cloakhq/cloakbrowser:latest

# Environment defaults
# CDP_HOST — bind address for CloakBrowser CDP (0.0.0.0 = all interfaces)
# CDP_PORT — CloakBrowser CDP (cloakserve default is 9222)
# MCP_PORT — @playwright/mcp HTTP/SSE transport
ENV CDP_HOST=0.0.0.0
ENV CDP_PORT=9222
ENV MCP_PORT=3000
ENV HEADLESS=true
ENV PROXY_SERVER=""
ENV STORAGE_STATE=""
ENV ISOLATED=false

# Install @playwright/mcp (Node.js is already in cloakhq/cloakbrowser)
RUN npm install -g @playwright/mcp@latest

# Copy entrypoint (must exist in build context)
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Ports
EXPOSE ${CDP_PORT} ${MCP_PORT}

# Healthcheck
HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -sf "http://127.0.0.1:${CDP_PORT}/json/version" || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
