# CloakBrowser MCP

**MCP server** powered by [CloakBrowser](https://github.com/CloakHQ/CloakBrowser) — stealth Chromium with 26 C++ patches.

Anti-detect browser + MCP server in a single Docker image. Connect to Claude, Cursor, VS Code, Codex — any MCP client.

## Architecture

```
┌─────────────────────────────────────────┐
│          Docker Container               │
│                                         │
│  ┌──────────────┐    ┌───────────────┐ │
│  │ CloakBrowser  │───▶│ @playwright/  │ │
│  │ (CDP :9222)   │    │ mcp (:3000)  │ │
│  │ stealth       │    │ SSE transport │ │
│  │ Chromium      │    │               │ │
│  └──────────────┘    └───────────────┘ │
└─────────────────────────────────────────┘
       │                    │
       ▼                    ▼
   CDP debugging      MCP clients
   (optional)         (Claude, VS Code...)
```

## Project Files

| File | Description |
|---|---|
| `Dockerfile` | CloakBrowser + @playwright/mcp |
| `docker-entrypoint.sh` | Startup: CDP → MCP |
| `docker-compose.yml` | Compose config |

## Quick Start

```bash
# Run
docker compose up -d

# Check logs
docker logs -f cloakbrowser-mcp
```

## Connecting MCP Clients

### VS Code / Cursor / Windsurf

```jsonc
{
  "mcpServers": {
    "cloakbrowser": {
      "url": "http://localhost:3000"
    }
  }
}
```

### Codex

```bash
codex mcp add cloakbrowser http://localhost:3000
```

Or in `~/.codex/config.toml`:

```toml
[mcp_servers.cloakbrowser]
url = "http://localhost:3000"
```

### OpenClaw

```yaml
mcpServers:
  cloakbrowser:
    url: http://localhost:3000
```

## Capabilities

All `@playwright/mcp` tools:

| Tool | Description |
|---|---|
| `browser_navigate` | Navigate to URL |
| `browser_snapshot` | Accessibility snapshot |
| `browser_click` | Click element |
| `browser_type` | Type text |
| `browser_select_option` | Select dropdown option |
| `browser_hover` | Hover over element |
| `browser_press_key` | Press key |
| `browser_file_upload` | Upload files |
| `browser_drag` | Drag & drop |
| `browser_screenshot` | Take screenshot |
| `browser_evaluate` | Execute JavaScript |
| `browser_network_requests` | Network request log |
| `browser_tabs` | Tab management |
| `browser_wait_for` | Wait for elements |
| `browser_go_back/forward` | Navigation |

## Environment Variables

### CloakBrowser (CDP Backend)

| Variable | Default | Description |
|---|---|---|
| `CDP_HOST` | `0.0.0.0` | CloakBrowser CDP bind address |
| `CDP_PORT` | `9222` | CloakBrowser CDP port |
| `HEADLESS` | `true` | Set to `false` for headed mode (requires X11) |
| `PROXY_SERVER` | _(unset)_ | Proxy: `http://user:pass@host:port` |

### @playwright/mcp (MCP Frontend)

| Variable | Default | MCP Flag | Description |
|---|---|---|---|
| `MCP_HOST` | `0.0.0.0` | `--host` | MCP server bind address |
| `MCP_PORT` | `3000` | `--port` | MCP server port (SSE) |
| `MCP_ISOLATED` | _(unset)_ | `--isolated` | In-memory browser profile |
| `STORAGE_STATE` | _(unset)_ | `--storage-state` | Path to cookies/localStorage JSON |
| `USER_DATA_DIR` | _(unset)_ | `--user-data-dir` | Custom browser profile directory |
| `VIEWPORT_SIZE` | _(unset)_ | `--viewport-size` | Window size, e.g. `1920x1080` |
| `DEVICE` | _(unset)_ | `--device` | Device emulation, e.g. `iPhone 15` |
| `USER_AGENT` | _(unset)_ | `--user-agent` | Custom User-Agent |
| `CAPS` | _(unset)_ | `--caps` | Comma-separated capabilities: `vision`, `pdf`, `devtools` |
| `PROXY_BYPASS` | _(unset)_ | `--proxy-bypass` | Bypass proxy for domains, e.g. `localhost,*.internal.com` |
| `TIMEOUT_ACTION` | _(unset)_ | `--timeout-action` | Action timeout in ms (default 5000) |
| `TIMEOUT_NAVIGATION` | _(unset)_ | `--timeout-navigation` | Navigation timeout in ms (default 60000) |
| `CONSOLE_LEVEL` | _(unset)_ | `--console-level` | Console log level: `error`, `warning`, `info`, `debug` |
| `IGNORE_HTTPS_ERRORS` | _(unset)_ | `--ignore-https-errors` | Ignore HTTPS errors |
| `BLOCK_SERVICE_WORKERS` | _(unset)_ | `--block-service-workers` | Block service workers |
| `BLOCKED_ORIGINS` | _(unset)_ | `--blocked-origins` | Blocked origins (semicolon-separated) |
| `ALLOWED_ORIGINS` | _(unset)_ | `--allowed-origins` | Allowed origins (semicolon-separated) |
| `GRANT_PERMISSIONS` | _(unset)_ | `--grant-permissions` | Browser permissions (comma-separated) |
| `SAVE_SESSION` | _(unset)_ | `--save-session` | Save session to output directory |
| `OUTPUT_DIR` | _(unset)_ | `--output-dir` | Output directory for files |
| `INIT_SCRIPT` | _(unset)_ | `--init-script` | Path to JS init script |
| `INIT_PAGE` | _(unset)_ | `--init-page` | Path to TS page init script |
| `SECRETS_FILE` | _(unset)_ | `--secrets` | Path to dotenv secrets file |
| `ALLOW_UNRESTRICTED_FILE_ACCESS` | _(unset)_ | `--allow-unrestricted-file-access` | Allow file access outside workspace |
| `BROWSER` | _(unset)_ | `--browser` | Browser: `chrome`, `firefox`, `webkit`, `msedge` |
| `CDP_HEADERS` | _(unset)_ | `--cdp-header` | CDP request headers |
| `CDP_TIMEOUT` | _(unset)_ | `--cdp-timeout` | CDP connection timeout in ms |
| `CODEGEN` | _(unset)_ | `--codegen` | Codegen language: `typescript`, `none` |
| `MCP_CONFIG` | _(unset)_ | `--config` | Path to MCP config file |
| `EXECUTABLE_PATH` | _(unset)_ | `--executable-path` | Path to browser executable |
| `EXTENSION` | _(unset)_ | `--extension` | Connect via Playwright Extension |
| `MCP_HEADLESS` | _(unset)_ | `--headless` | Run browser in headless mode |
| `IMAGE_RESPONSES` | _(unset)_ | `--image-responses` | Image responses: `allow`, `omit` |
| `NO_SANDBOX` | _(unset)_ | `--no-sandbox` | Disable browser sandbox |
| `OUTPUT_MODE` | _(unset)_ | `--output-mode` | Output mode: `file`, `stdout` |
| `MCP_PROXY_SERVER` | _(unset)_ | `--proxy-server` | Proxy for MCP (separate from CloakBrowser) |
| `SANDBOX` | _(unset)_ | `--sandbox` | Enable browser sandbox |
| `SHARED_BROWSER_CONTEXT` | _(unset)_ | `--shared-browser-context` | Share browser context across clients |
| `SNAPSHOT_MODE` | _(unset)_ | `--snapshot-mode` | Snapshot mode: `full`, `none` |
| `TEST_ID_ATTRIBUTE` | _(unset)_ | `--test-id-attribute` | Test ID attribute (default `data-testid`) |

## Docker Image

Automatically built and published via GitHub Actions → GHCR:

**https://ghcr.io/isklv/cloakbrowser-mcp**

| Tag | When |
|---|---|
| `latest` | Latest push to `main` |
| `main` | Main branch |
| `sha-<commit>` | Specific commit |
| `v1.2.3`, `v1.2` | Semantic version tags (`git tag v1.2.3`) |

```bash
docker run -d --name cloakbrowser-mcp \
  -p 3000:3000 \
  ghcr.io/isklv/cloakbrowser-mcp:latest
```

## Examples

### With Proxy

```bash
docker run -d --name cloakbrowser-mcp \
  -e PROXY_SERVER=http://user:pass@proxy:8080 \
  -p 3000:3000 \
  ghcr.io/isklv/cloakbrowser-mcp:latest
```

### Headed Mode (Xvfb)

```bash
docker run -d --name cloakbrowser-mcp \
  -e HEADLESS=false \
  -p 3000:3000 \
  ghcr.io/isklv/cloakbrowser-mcp:latest
```

### Persist Session

```bash
docker run -d --name cloakbrowser-mcp \
  -v ./storage-state.json:/app/storage-state.json \
  -e STORAGE_STATE=/app/storage-state.json \
  -p 3000:3000 \
  ghcr.io/isklv/cloakbrowser-mcp:latest
```

## Direct CDP Access

Port 9222 is exposed for debugging. Connect from Playwright:

```python
from playwright.sync_api import sync_playwright

pw = sync_playwright().start()
browser = pw.chromium.connect_over_cdp("http://localhost:9222")
page = browser.new_page()
page.goto("https://example.com")
print(page.title())
```

## Build Manually

```bash
cd cloakbrowser-mcp
docker build -t cloakbrowser-mcp .
```

The image is automatically built and published to GHCR on every push to `main` via [GitHub Actions](https://github.com/isklv/cloakbrowser-mcp/actions).

## Security

⚠️ CDP gives full control over the browser. Never expose port 9222 to the internet without authentication.

```bash
# Safe — localhost only
docker run -p 127.0.0.1:9222:9222 -p 127.0.0.1:3000:3000 ...
```

## License

MIT. CloakBrowser binary — [Binary License](https://github.com/CloakHQ/CloakBrowser/blob/main/BINARY-LICENSE.md).
