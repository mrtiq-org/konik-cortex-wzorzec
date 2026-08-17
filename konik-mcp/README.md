# konik-mcp v0.1 — portal KONIK w Claude klienta (read-only)

Pięć narzędzi: `portal_przeglad` · `akceptacje` · `kalendarz_publikacji` ·
`dokumenty_marki` · `drugi_mozg`. Serwer NICZEGO nie zapisuje — akceptacje
wyłącznie w portalu (zapis = v2, po pilocie i decyzji 6 z CORTEX-PLAN.md).

## Instalacja

**Normalnie nie robi się tego ręcznie.** Instalator vaulta kopiuje serwer do
`~/.konik/konik-mcp`, ściąga zależności i wpina go do Claude Desktop:

```bash
./instalator/instaluj.sh "Nazwa Firmy" ~/Cortex-Firma "Imie Kuratora"
```

(na Windowsie: `.\instalator\instaluj.ps1 -Firma … -Cel … -Kurator …`)

Instalator pyta o `client-id` i token, a wpis dopisuje przez
[`narzedzia/rejestruj-mcp.js`](../narzedzia/rejestruj-mcp.js) — **scalając**,
nie nadpisując: inne serwery MCP klienta zostają nietknięte, a plik dostaje
kopię zapasową z datą.

## Konfiguracja ręczna (awaryjnie)

Gdy instalator nie może pójść — np. Claude Desktop trzyma konfigurację w
nietypowym miejscu. Plik: macOS
`~/Library/Application Support/Claude/claude_desktop_config.json`, Windows
`%APPDATA%\Claude\claude_desktop_config.json`.

```json
{
  "mcpServers": {
    "konik-portal": {
      "command": "node",
      "args": ["/Users/<user>/.konik/konik-mcp/index.js"],
      "env": {
        "KONIK_API_URL": "https://dev.koniksystems.com",
        "KONIK_TOKEN": "<JWT z panelu klienta>",
        "KONIK_CLIENT_ID": "<id konta klienta>"
      }
    }
  }
}
```

Wcześniej `npm install --omit=dev` w katalogu serwera (2 zależności: oficjalne
SDK MCP + zod). Po każdej zmianie pliku — restart Claude Desktop.

## Ograniczenia v1 (świadome)

- **Token wygasa** — po wygaśnięciu każde narzędzie zwraca czytelny komunikat
  z instrukcją odnowienia (nie ciche pustki). Model docelowy auth = decyzja 6.
- Desktop only (MCP nie działa na telefonie) — mobile idzie przez portal.
- Read-only — vault NIE wysyła niczego do KONIKA, połączenie jest jednokierunkowe.

## Smoke (wykonany 2026-08-09 na lokalnym stacku)

initialize → tools/list (5 narzędzi) → `drugi_mozg` zwraca stan wdrożenia
z API · zły token → `isError` + komunikat o wygasłej sesji. Powtórka: pipe
JSON-RPC po stdio jak w CORTEX-TESTPLAN.md (KONIK CORE).

Instalator (obie wersje) przetestowany 2026-08-16 na czystym katalogu: scalanie
konfiguracji z istniejącym serwerem MCP, zachowanie ręcznie wpisanego tokenu
przy ponownym uruchomieniu, odmowa nadpisania uszkodzonego JSON-a.
