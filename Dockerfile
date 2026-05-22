# syntax=docker/dockerfile:1
FROM cloakhq/cloakbrowser:latest

# Environment defaults
ENV PORT=8931
ENV HOST=0.0.0.0
ENV HEADLESS=true
ENV PROXY_SERVER=""

# Create entrypoint script
RUN mkdir -p /docker-entrypoint.d && \
    cat > /docker-entrypoint.sh << 'ENTRYPOINT'
#!/bin/bash
set -e

# Build cloakserve arguments
ARGS=()

# Headless mode
if [ "${HEADLESS}" = "false" ]; then
  ARGS+=(--headless=false)
fi

# Proxy
if [ -n "${PROXY_SERVER}" ]; then
  ARGS+=(--proxy-server="${PROXY_SERVER}")
fi

# Start cloakserve on the configured port
# cloakserve binds to 0.0.0.0 by default in Docker
exec cloakserve --remote-debugging-port="${PORT}" "${ARGS[@]}"
ENTRYPOINT

RUN chmod +x /docker-entrypoint.sh

# Expose the CDP port
EXPOSE ${PORT}

# Healthcheck — check if CDP is responding
HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:${PORT}/json/version')" || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
