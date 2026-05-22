# CloakBrowser MCP — Docker CDP Server

Docker-обёртка над [CloakBrowser](https://github.com/CloakHQ/CloakBrowser) для запуска stealth Chromium как CDP-сервера. Аналог `playwright/mcp`, но с антидетект-браузером.

## Быстрый старт

```bash
# Запуск
docker run -d --name cloakbrowser -p 8931:8931 isklv/cloakbrowser-mcp

# Или через docker-compose
docker compose up -d
```

## Подключение через CDP

```python
from playwright.sync_api import sync_playwright

pw = sync_playwright().start()
browser = pw.chromium.connect_over_cdp("http://localhost:8931")
page = browser.new_page()
page.goto("https://example.com")
print(page.title())
browser.close()
```

```javascript
const { chromium } = require('playwright');

const browser = await chromium.connectOverCDP('http://localhost:8931');
const page = await browser.newPage();
await page.goto('https://example.com');
console.log(await page.title());
await browser.close();
```

## Переменные окружения

| Переменная       | По умолчанию | Описание                              |
|------------------|-------------|---------------------------------------|
| `PORT`           | `8931`      | Порт CDP-сервера                      |
| `HOST`           | `0.0.0.0`   | Хост для привязки                     |
| `HEADLESS`       | `true`      | `false` для headed режима (Xvfb)      |
| `PROXY_SERVER`   | ``          | Прокси: `http://user:pass@host:port`  |

## Примеры

### С прокси

```bash
docker run -d --name cloakbrowser \
  -p 8931:8931 \
  -e PROXY_SERVER=http://user:pass@proxy:8080 \
  isklv/cloakbrowser-mcp
```

### Headed режим

```bash
docker run -d --name cloakbrowser \
  -p 8931:8931 \
  -e HEADLESS=false \
  isklv/cloakbrowser-mcp
```

### На другом порту

```bash
docker run -d --name cloakbrowser \
  -p 9222:9222 \
  -e PORT=9222 \
  isklv/cloakbrowser-mcp
```

## Сборка своего образа

```bash
docker build -t my-cloakbrowser .
```

## Healthcheck

Встроенный healthcheck проверяет доступность CDP endpoint каждые 10 секунд.

## Лицензия

MIT. Бинарник CloakBrowser — [Binary License](https://github.com/CloakHQ/CloakBrowser/blob/main/BINARY-LICENSE.md).
