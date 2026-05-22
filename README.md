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

### CloakBrowser (CDP backend)

| Переменная | По умолчанию | Описание |
|---|---|---|
| `CDP_HOST` | `0.0.0.0` | Хост для CloakBrowser CDP |
| `CDP_PORT` | `9222` | Порт CDP (CloakBrowser) |
| `HEADLESS` | `true` | `false` для headed режима (требует X11) |
| `PROXY_SERVER` | `` | Прокси-сервер: `http://user:pass@host:port` |

### @playwright/mcp (MCP frontend)

| Переменная | По умолчанию | Флаг MCP | Описание |
|---|---|---|---|
| `MCP_HOST` | `0.0.0.0` | `--host` | Хост MCP-сервера |
| `MCP_PORT` | `3000` | `--port` | Порт MCP-сервера (SSE) |
| `MCP_ISOLATED` | `false` | `--isolated` | Изолированный браузерный контекст |
| `STORAGE_STATE` | `` | `--storage-state` | Путь к JSON с куками/localStorage |
| `USER_DATA_DIR` | `` | `--user-data-dir` | Пользовательская директория профиля |
| `VIEWPORT_SIZE` | `` | `--viewport-size` | Размер окна, напр. `1920x1080` |
| `DEVICE` | `` | `--device` | Эмуляция устройства, напр. `iPhone 15` |
| `USER_AGENT` | `` | `--user-agent` | Кастомный User-Agent |
| `CAPS` | `` | `--caps` | Способности (через запятую), напр. `core,network,vision` |
| `PROXY_BYPASS` | `` | `--proxy-bypass` | Пропускать через прокси, напр. `localhost,*.internal.com` |
| `TIMEOUT_ACTION` | `` | `--timeout-action` | Таймаут действия в мс (по умолч. 5000) |
| `TIMEOUT_NAVIGATION` | `` | `--timeout-navigation` | Таймаут навигации в мс (по умолч. 60000) |
| `CONSOLE_LEVEL` | `` | `--console-level` | Уровень лога: `error`, `warning`, `info`, `debug` |
| `IGNORE_HTTPS_ERRORS` | `false` | `--ignore-https-errors` | Игнорировать ошибки HTTPS |
| `BLOCK_SERVICE_WORKERS` | `false` | `--block-service-workers` | Блокировать Service Workers |
| `BLOCKED_ORIGINS` | `` | `--blocked-origins` | Запрещённые домены (через запятую) |
| `ALLOWED_ORIGINS` | `` | `--allowed-origins` | Разрешённые домены (через запятую) |
| `GRANT_PERMISSIONS` | `` | `--grant-permissions` | Разрешения браузера (через запятую) |
| `SAVE_SESSION` | `false` | `--save-session` | Сохранять данные сессии |
| `OUTPUT_DIR` | `` | `--output-dir` | Директория для вывода |
| `INIT_SCRIPT` | `` | `--init-script` | Путь к JS-скрипту инициализации |
| `INIT_PAGE` | `` | `--init-page` | Путь к TS-скрипту инициализации страницы |
| `SECRETS_FILE` | `` | `--secrets` | Путь к dotenv-файлу с секретами |
| `ALLOW_UNRESTRICTED_FILE_ACCESS` | `false` | `--allow-unrestricted-file-access` | Доступ к файлам вне workspace |
| `BROWSER` | `` | `--browser` | Браузер: `chrome`, `firefox`, `webkit`, `msedge` |
| `CDP_HEADERS` | `` | `--cdp-header` | Заголовки CDP-запроса |
| `CDP_TIMEOUT` | `` | `--cdp-timeout` | Таймаут подключения к CDP в мс |
| `CODEGEN` | `` | `--codegen` | Язык генерации кода: `typescript`, `none` |
| `MCP_CONFIG` | `` | `--config` | Путь к конфигурационному файлу |
| `EXECUTABLE_PATH` | `` | `--executable-path` | Путь к бинарнику браузера |
| `EXTENSION` | `false` | `--extension` | Подключение через Playwright Extension |
| `MCP_HEADLESS` | `` | `--headless` | Запуск браузера в headless-режиме |
| `IMAGE_RESPONSES` | `` | `--image-responses` | Режим изображений: `allow`, `omit` |
| `NO_SANDBOX` | `false` | `--no-sandbox` | Отключить sandbox браузера |
| `OUTPUT_MODE` | `` | `--output-mode` | Режим вывода: `file`, `stdout` |
| `MCP_PROXY_SERVER` | `` | `--proxy-server` | Прокси для MCP (отдельно от CloakBrowser) |
| `SANDBOX` | `false` | `--sandbox` | Включить sandbox браузера |
| `SHARED_BROWSER_CONTEXT` | `false` | `--shared-browser-context` | Общий контекст для всех клиентов |
| `SNAPSHOT_MODE` | `` | `--snapshot-mode` | Режим снимков: `full`, `none` |
| `TEST_ID_ATTRIBUTE` | `` | `--test-id-attribute` | Атрибут для test-id (по умолч. `data-testid`) |

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
