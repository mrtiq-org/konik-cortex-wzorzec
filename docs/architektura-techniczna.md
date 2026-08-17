# KONIK Cortex — dokumentacja techniczna v1.0 (stan 2026-08-09)

Dwa kodebase'y: **repo wzorca** (to repo — strona kliencka) i **KONIK CORE**
(platforma — commit `c25f12e` na main). Spina je HTTP API + serwer MCP.

## 1. Repo wzorca — drzewo

```
konik-cortex-wzorzec/
├── wzorzec-vaulta/            # szablon kopiowany instalatorem per klient
│   ├── 00-START/              # Mapa Firmy.md, Jak korzystać…, Kontrakt Danych.md
│   ├── 01-PROCEDURY/{Sprzedaz,Operacje,Finanse,Kadry,Awarie}/   # SOP-01 w Kadry
│   ├── 02-SPOTKANIA/2026/  03-KONTA/  04-PROJEKTY/{Aktywne,Zamkniete}/
│   ├── 05-DECYZJE/  06-WIEDZA/(5 podfolderów)  07-ZESPOL/  99-ARCHIWUM/
│   ├── 08-SZABLONY/           # 5 szablonów z pełnym frontmatterem
│   ├── 09-PROMPTY/            # 10 notatek-promptów z polem `zastosowanie:`
│   └── .claude/
│       ├── CLAUDE.md          # reguły asystenta (patrz §3)
│       ├── skills/{notatka-ze-spotkania,nowa-procedura,przeglad-miesieczny,zrzut-statusu}/SKILL.md
│       └── output-styles/konkret.md
├── instalator/instaluj.ps1 + instaluj.sh
├── narzedzia/lint-rodo.js
├── konik-mcp/{package.json,index.js,README.md}
├── testy-regresji/CHECKLISTA.md   # 12 testów przed aktualizacją komponentów
├── docs/                          # karta usługi, kontrakt danych, skrypt D0, BUR, runbook
└── WERSJE.md                      # rejestr wersji (§10 Kontraktu Danych)
```

## 2. Kontrakt danych notatki (frontmatter YAML)

```yaml
typ: sop|spotkanie|konto|projekt|decyzja|wiedza|osoba
tytul:  wlasciciel:  status: szkic|obowiazuje|do-przegladu|wycofane
utworzono: RRRR-MM-DD   przeglad: RRRR-MM-DD   wersja: "1.0"
strefa: ogolna|dzialowa|sejf   crm_id:   tagi: []
```
Widoki (Obsidian Bases/Dataview, Notion: widoki baz) filtrują po `przeglad`,
`wlasciciel`, `status`. Notatka bez frontmattera „nie istnieje" dla systemu.

## 3. Warstwa Claude (LOCAL)

Claude Code otwarty w katalogu vaulta: czyta/pisze pliki natywnie, ładuje
CLAUDE.md + skille automatycznie. **Bez wtyczek Obsidiana** (Obsidian = tylko
edytor tych samych .md). Reguły z CLAUDE.md: (a) każda odpowiedź ze wskazaniem
notatki źródłowej, (b) zapis wyłącznie `02-SPOTKANIA` i `05-DECYZJE` — do SOP
tylko propozycja diffa, (c) dane osobowe wycinane, zastępowane `crm_id`+rolą.
Skille = katalogi z SKILL.md (frontmatter name/description + kroki procedury).
Claude Desktop wymaga plikowego serwera MCP — pozycja w CHECKLIST regresji.

## 4. Instalator (przetestowany e2e, ~30 s)

`instaluj.ps1 -Firma X -Cel D:\vault -Kurator Y` → kopiuje wzorzec, usuwa
.gitkeep → podstawia `{{FIRMA}}/{{KURATOR}}/{{data}}` we wszystkich .md
(UTF-8 bez BOM) → kopiuje lint do `.narzedzia/` + uruchamia (fail = błąd
wzorca) → `git init -b main` z LOKALNĄ tożsamością (maszyna klienta nie ma
globalnej) → hook `.git/hooks/pre-commit` → commit startowy → kroki ręczne.

## 5. lint-rodo.js (Node, zero deps)

Rekurencyjny skan `.md` (skip: .git/.obsidian/node_modules). Detektory:
e-mail (regex), telefon (`+48…` lub `\d{3}[ -]\d{3}[ -]\d{3}`), PESEL —
`\b\d{11}\b` **plus walidacja sumy kontrolnej** (wagi 1,3,7,9…, cyfra
kontrolna) — bez tego łapałby numery faktur. Linia z `rodo:ok` pomijana
(jawny wyjątek dla danych fikcyjnych). Znalezisko → stderr `plik:linia — typ`
→ exit 1 → pre-commit blokuje. Potwierdzone mutacyjnie.

## 6. konik-mcp (Node ESM, @modelcontextprotocol/sdk + zod)

`McpServer` + `StdioServerTransport`. 5 narzędzi read-only zdefiniowanych
tabelą `[name, description, path]` → każde `tools/call` = `fetch(API+path)`
z nagłówkami `Authorization: Bearer $KONIK_TOKEN` + `x-client-id`.
Env: `KONIK_API_URL` (default dev.koniksystems.com), `KONIK_TOKEN`,
`KONIK_CLIENT_ID`. 401 → `isError:true` + komunikat „zaloguj się i odśwież
token" (nie cicha pustka). Smoke: initialize → tools/list (5) → call OK.

## 7. Strona platformy (KONIK CORE, commit c25f12e)

- **DB (migracja `database/096_cortex_deployments.sql`):** `cortex_deployments`
  (UNIQUE client_id; `sciezka` CHECK local|team|dual; 9 kolumn `*_at` etapów;
  `przeglad_next_date`, `backup_last_at`; `checklist` jsonb mapa klucz→bool;
  `komponenty` jsonb; RLS idiom 095) + `cortex_events` (append-only, type:
  created|stage_done|stage_undo|checklist|backup|przeglad|edit|note).
- **`src/activities/db/cortex_repo.ts`:** get/create/update + appendCortexEvent;
  service-role, jawny client_id, błąd DB = wyjątek.
- **`src/activities/portal/cortex_state.ts`** (czyste funkcje): `CORTEX_STAGES`
  (9 etapów: kwalifikacja→…→odbior→przeglad_30→raport_90, mapowanie key→kolumna),
  `CORTEX_CHECKLIST` (14 pozycji), `buildCortexSteps` (liniowo: done/running/
  ready; odbiór blocked przy checkliście <14), `assertStageCompletable`
  (UNKNOWN_STAGE/STAGE_NOT_CURRENT/GATE_CHECKLIST), `assertStageUndoable`
  (tylko ostatni done), `buildCortexView` (faza=obsluga po odbiorze; backup
  stale >48h; przegląd overdue), `invalidChecklistKeys`.
- **`src/api/routers/cortex.ts`:** GET (requireClientId; brak wiersza →
  `{enabled:false}`; awaria → 500) · POST {sciezka} (requireActingStaff =
  `req.actorUserId` z impersonacji; 409 duplikat) · PATCH (stageDone/stageUndo/
  checklist/sciezka/kurator*/przegladNextDate/backupNow/komponenty/note —
  walidacja PRZED zapisem, znaczniki czasu SERWERA, event per zmiana).
- **Front:** `dashboard/src/api/cortex.ts` (typy+fetch), `PortalCortexPage.tsx`
  (`/panel/drugi-mozg`, komponenty IosScreen/IosSection/IosRow; akcje PM za
  `isImpersonating`; sekcje: etapy, checklista, opieka, wersje, formularz PM).
- **Testy:** `cortex_state.test.ts` (20) + `cortex_endpoint.test.ts` (20),
  mutacje ×2; e2e mock-stack (seed w `scripts/dev-mock-supabase.js`).

## 8. Znane braki v1

TEAM/Notion nieodwzorowany · Sejf (Ollama) niekonfigurowany · vault demo brak ·
widoki Bases ręcznie · auth MCP = wygasający JWT (decyzja 6) · deploy na prod
wstrzymany (DEPLOY_PAT), migracja 096 na prodzie niepotwierdzona.
