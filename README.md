# konik-cortex-wzorzec

Wzorzec produktu **KONIK Cortex / Firmowy Drugi Mózg**: baza wiedzy klienta
(Obsidian LOCAL / Notion TEAM / DUAL) + asystent Claude + warstwa `.claude/`.
Każde wdrożenie klienckie to **klon tego wzorca przez instalator** — nigdy
budowa od zera. Plan produktu i decyzje: KONIK CORE →
`.clean-room/10_SPRINT/CORTEX-PLAN.md`.

## Struktura repo

| Katalog | Co |
|---|---|
| `wzorzec-vaulta/` | Kompletny vault-szablon: foldery 00–99, 5 szablonów, 10 promptów, SOP-01, warstwa `.claude/` (CLAUDE.md, 4 skille, output-style) |
| `instalator/` | `przygotuj-maszyne.ps1` / `.sh` — krok zero: Node.js, git, Obsidian, Claude Desktop (winget / Homebrew); `instaluj.ps1` / `.sh` — pusty katalog → działający vault z gitem i lintem RODO (z `-Remote` / `KONIK_REMOTE` wypycha do wspólnego repo zespołu); `dolacz.ps1` / `.sh` — kolejna osoba w firmie klonuje wspólne repo i dostaje hook RODO, tożsamość, MCP |
| `narzedzia/` | `lint-rodo.js` — blokada danych osobowych w commitach vaulta |
| `testy-regresji/` | Checklista 12 testów przed KAŻDĄ aktualizacją komponentów u klientów |
| `docs/` | Dokumenty produktu: karta usługi, Kontrakt Danych, skrypt kwalifikacyjny, karty BUR, runbook |
| `WERSJE.md` | Rejestr wersji komponentów (§10 Kontraktu Danych) — aktualizacja TYLKO po przebiegu regresji |

## Szybki start (wdrożenie testowe)

```powershell
.\instalator\instaluj.ps1 -Firma "Testowa" -Cel "C:\Vaulty\Testowa" -Kurator "Jan Testowy"
```

Instalator: kopiuje wzorzec, podstawia `{{FIRMA}}`/`{{KURATOR}}`/`{{data}}`,
odpala lint RODO, zakłada git z hookiem pre-commit i robi commit startowy.
Bramka produktu: **cała instalacja < 15 minut** łącznie z krokami ręcznymi.

## Zasady pracy nad wzorcem

- Zmiana w rdzeniu wzorca obowiązuje KAŻDEGO przyszłego klienta — jeśli
  wdrożenie wymaga zmian w rdzeniu, poprawiamy wzorzec, nie pojedynczą instalację.
- Warstwa branżowa to WYŁĄCZNIE: podfolder w `01-PROCEDURY`, 2–3 dodatkowe
  szablony i słownik pojęć w `06-WIEDZA`. Nic więcej.
- Aktualizacja wersji komponentu (Obsidian/wtyczki/Claude): najpierw pełny
  przebieg `testy-regresji/CHECKLISTA.md` na wzorcu, potem wpis w `WERSJE.md`,
  dopiero potem klienci — w oknie serwisowym.
- Dane osobowe nie wchodzą do wzorca ani do vaultów (lint blokuje commit);
  fikcyjne dane demo wyłącznie ze znacznikiem `rodo:ok` w linii.
