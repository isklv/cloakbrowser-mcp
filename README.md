# CloakBrowser MCP

**Модельный контекстно-протокольный сервер** на базе [CloakBrowser](https://github.com/CloakHQ/CloakBrowser) — stealth Chromium с 26 C++ патчами.

Антидетект-браузер + MCP-сервер в одном Docker-образе. Подключай к Claude, Cursor, VS Code, Codex — любому MCP-клиенту.

## Архитектура

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
   CDP отладка      MCP клиенты
   (опционально)    (Claude, VS Code...)
```

## Файлы проекта

| Файл | Описание |
|---|---|
| `Dockerfile` | CloakBrowser + @playwright/mcp |
| `docker-entrypoint.sh` | Запуск CDP → MCP |
| `docker-compose.yml` | Compose-конфиг |
| `*.container`, `*.image` | Quadlet (Bazzite/Fedora) |

## Быстрый старт

```bash
# Запуск
docker compose up -d

# Проверка
docker logs -f cloakbrowser-mcp
```

## Подключение к MCP-клиенту

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

Или в `~/.codex/config.toml`:

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

## Что умеет

Все инструменты `@playwright/mcp`:

| Инструмент | Описание |
|---|---|
| `browser_navigate` | Переход по URL |
| `browser_snapshot` | Accessibility-снимок страницы |
| `browser_click` | Клик по элементу |
| `browser_type` | Ввод текста |
| `browser_select_option` | Выбор в dropdown |
| `browser_hover` | Наведение курсора |
| `browser_press_key` | Нажатие клавиши |
| `browser_file_upload` | Загрузка файлов |
| `browser_drag` | Drag & drop |
| `browser_screenshot` | Скриншот |
| `browser_evaluate` | Выполнение JS |
| `browser_network_requests` | Лог сетевых запросов |
| `browser_tabs` | Управление вкладками |
| `browser_wait_for` | Ожидание элементов |
| `browser_go_back/forward` | Навигация |

## Переменные окружения

| Переменная | По умолчанию | Описание |
|---|---|---|
| `CDP_PORT` | `9222` | Порт CDP (CloakBrowser) |
| `MCP_PORT` | `3000` | Порт MCP-сервера (SSE) |
| `HEADLESS` | `true` | `false` для headed режима |
| `PROXY_SERVER` | `` | Прокси: `http://user:pass@host:port` |
| `ISOLATED` | `false` | Изолированный браузерный контекст |
| `STORAGE_STATE` | `` | Путь к JSON с куками/localStorage |

## Примеры

### С прокси

```bash
docker run -d --name cloakbrowser-mcp \
  -e PROXY_SERVER=http://user:pass@proxy:8080 \
  -p 3000:3000 \
  isklv/cloakbrowser-mcp
```

### Headed режим (Xvfb)

```bash
docker run -d --name cloakbrowser-mcp \
  -e HEADLESS=false \
  -p 3000:3000 \
  isklv/cloakbrowser-mcp
```

### Сохранение сессии

```bash
# Mount storage state
docker run -d --name cloakbrowser-mcp \
  -v ./storage-state.json:/app/storage-state.json \
  -e STORAGE_STATE=/app/storage-state.json \
  -p 3000:3000 \
  isklv/cloakbrowser-mcp
```

## Прямой доступ к CDP

Порт 9222 открыт для отладки. Подключайся из Playwright:

```python
from playwright.sync_api import sync_playwright

pw = sync_playwright().start()
browser = pw.chromium.connect_over_cdp("http://localhost:9222")
page = browser.new_page()
page.goto("https://example.com")
print(page.title())
```

## Сборка

```bash
cd cloakbrowser-mcp
docker build -t cloakbrowser-mcp .
```

## Push на Docker Hub

```bash
docker tag cloakbrowser-mcp isklv/cloakbrowser-mcp:latest
docker push isklv/cloakbrowser-mcp:latest
```

## Безопасность

⚠️ CDP даёт полный контроль над браузером. Не открывай порт 9222 в интернет без авторизации.

```bash
# Безопасно — только localhost
docker run -p 127.0.0.1:9222:9222 -p 127.0.0.1:3000:3000 ...
```

## Лицензия

MIT. CloakBrowser binary — [Binary License](https://github.com/CloakHQ/CloakBrowser/blob/main/BINARY-LICENSE.md).
