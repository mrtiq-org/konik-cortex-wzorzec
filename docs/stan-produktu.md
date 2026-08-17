# KONIK Cortex — co mamy gotowe i jak to działa (stan 2026-08-13)

## 1. Co jest NA PRODUKCJI (dev.koniksystems.com)

| Moduł | Co robi | Stan |
|---|---|---|
| **Zakładka „Drugi Mózg"** (`/panel/drugi-mozg`) | Oś 9 etapów wdrożenia z bramkami (Kontrakt Danych przed budową, odbiór za checklistą 14/14), kurator, przeglądy, backup, wersje komponentów. Klient patrzy, PM prowadzi (przez impersonację) | ✅ działa, migracja 096 w bazie |
| **Głosówka → Notion** | Klient wciska 🎙️ → nagranie → Whisper → Claude wyciąga notatkę/wydarzenie/zadania/decyzje (dane osobowe wycinane podwójnie) → zapis do Notion klienta jego tokenem, z linkami do stron | ✅ działa; wymaga per klient: token integracji + ID baz w formularzu PM |
| **Portal jako PWA** | „Dodaj do ekranu głównego" na telefonie → ikona KONIK, pełny ekran, mikrofon działa (naprawiony nagłówek Permissions-Policy) | ✅ działa |
| **Powiadomienia Slack/Teams** (E2a) | Po udanej głosówce ping na kanał zespołu z tytułem i linkami; allowlista hostów (anty-SSRF) | ✅ kod na prodzie; **czeka na migrację 101** + webhook w formularzu PM |
| **Przypomnienia z obietnic** (G2) | Codziennie ~6 rano: zadania z głosówek z terminem DZIŚ/JUTRO → ping na webhook („Wycena (Marek) — termin jutro") | ✅ cron uzbrojony; kanał = ten sam webhook co E2a |

**Do zrobienia po stronie CTO (odblokowuje E2a+G2):** migracja `database/101_cortex_integrations.sql` w Supabase SQL Editor + wklejenie webhooka Slacka w portalu.

## 2. Jak działa łańcuch Głosówki (technicznie, w 5 krokach)

1. **Nagranie** w portalu/PWA (AudioRecorder, do 30 min, `audio/webm`) → signed-URL prosto do Storage (tor Transkryptora, migracja 097).
2. **Transkrypcja**: workflow Temporal (kolejka LONG, bez auto-retry — Whisper kosztuje) z mierzonym postępem.
3. **Ekstrakcja**: Claude → JSON {spotkanie, wydarzenie?, zadania[], decyzje[]}; scrub PII w promcie ORAZ w kodzie (`scrubPii`); halucynowane daty odrzucane.
4. **Zapis do Notion** klienta: klient REST schema-agnostyczny (pola title/date znajdowane po TYPIE — działa na dowolnej bazie); wynik = linki per artefakt.
5. **Dzwonek** na Slack/Teams (best-effort — nie unieważnia zapisu). Każda porażka etapu = czerwony status z powodem, zero wiecznego „przetwarzam".

## 3. Repo wzorca (`C:\Users\wikto\konik-cortex-wzorzec`, BEZ commita)

- **wzorzec-vaulta/**: struktura 00–99, 5 szablonów z frontmatterem, 10 promptów, SOP-01, `.claude/` (CLAUDE.md z regułą „zawsze źródło", 4 skille, output-style Konkret).
- **Instalator** (ps1+sh, przetestowany, ~30 s): kopiuje, podstawia {{FIRMA}}, git + hook lint-RODO (PESEL z sumą kontrolną — commit z danymi osobowymi BLOKOWANY).
- **konik-mcp** (5 narzędzi read-only — Claude klienta widzi portal; smoke zielony).
- **docs/**: karta usługi, Kontrakt Danych (draft→prawnik), skrypt kwalifikacyjny D0, runbook 10 dni, karty BUR 16h/40h, scenariusz testowy „Bosman", architektura techniczna, roadmapa A–H.

## 4. Zabezpieczenia wpisane w kod (nie w dobre chęci)

Zapis stanu wdrożenia tylko PM (403 dla klienta) · etapy wyłącznie po kolei ze znacznikiem SERWERA · odbiór za checklistą 14/14 · dane osobowe nie wchodzą (lint w vaulcie + scrub w Głosówce, mutacje potwierdzone) · token Notion nigdy nie wraca w API · webhooki tylko na oficjalne domeny (anty-SSRF) · brak konfiguracji Notion blokuje wydawanie pieniędzy na Whispera · każdy moduł fail-loud.

## 5. Infrastruktura przy okazji naprawiona

Deploy nie zależy już od tokenów GitHuba (serwer ciągnie mirror GitLab — koniec sagi „PAT wygasł") · nagłówek mikrofonu utrwalany idempotentnie przy każdym deployu · `gh` CLI zalogowany (monitorowanie runów bez tokenów w komendach).

## 6. Czego NIE ma (świadomie — czeka na kolejność)

TEAM/Notion jako gotowy szablon do duplikacji · Sejf (Ollama) · vault demo „Bosman" z treścią · pilot na Interkoordynacjach z pomiarem czasu PM · e2e Głosówki na żywych usługach (pierwszy test = CTO) · konta pracowników i limity pakietowe (H2/H3) · reszta roadmapy A–H.

## 7. Testy (wszystko z mutacjami)

Cortex state+endpoint 42 · Głosówka 17 · webhooki 5 (allowlista ×3 czerwienie) · przypomnienia 4 (mutacja ZŁAPAŁA ślepy test — naprawiony przed commitem). Łącznie **68 testów** w 6 plikach.
