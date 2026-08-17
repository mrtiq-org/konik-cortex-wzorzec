# Runbook wdrożenia klienckiego · 10 dni

Każde wdrożenie = klon wzorca przez instalator. Czas PM mierzymy per krok
(pilot: rozjazd >30% vs SOLO 3h / TEAM 12h / PRO 24h → korekta cennika).

## Oś procesu

| Dzień | Co | Artefakt / bramka |
|---|---|---|
| 0 | Kwalifikacja 45 min ([skrypt](skrypt-kwalifikacyjny.md)) | ścieżka + Kurator |
| 1–2 | Warsztat Inwentaryzacji Wiedzy | mapa: co wiemy, gdzie leży, co znika z ludźmi |
| 3 | **BRAMKA 1:** [Kontrakt Danych](kontrakt-danych.md) podpisany + Kurator | podpis |
| 4–7 | Budowa: instalator → migracja treści → 10 SOP z materiału warsztatu → AI | vault produkcyjny |
| 8 | Warsztat zespołu (2h / 16h / 40h BUR) | lista obecności |
| 9 | Rytuały + uprawnienia/strefy | harmonogram przeglądów w kalendarzu klienta |
| 10 | **BRAMKA 2:** odbiór — checklista 14/14 + baseline | protokół odbioru |
| +30 | Przegląd: ile SOP-ów dopisali sami | trigger upsellu „karmienie" |
| +90 | Raport Wartości | case study + kotwica retencji |

Postęp wdrożenia PM odhacza w portalu KONIK (zakładka „Drugi Mózg") — etapy
wyłącznie po kolei, odbiór odblokowuje się przy pełnej checkliście.

## Budowa per ścieżka (D4–7)

**Wspólne:** `instaluj.ps1 / instaluj.sh` (struktura+szablony+prompty+git+lint
< 15 min) → migracja wskazanych dokumentów → 10 SOP-ów wg priorytetu warsztatu
(kolejność pisania: 01 onboarding, 10 awarie, 02 kwalifikacja, 03 oferta — potem
reszta) → widoki kontrolne → backup + TEST odtworzenia.

**LOCAL (Obsidian+Claude):** Claude Desktop na maszynach klienta → serwer MCP
plikowy wskazujący na katalog vaulta (bez wtyczek Obsidiana, jeśli nie są
konieczne) → 3 zapytania kontrolne (odczyt listy / wyszukiwanie ze źródłem /
zapis testowy w 02-SPOTKANIA) → ograniczenie zapisu do 02/05. Nie obiecujemy mobile.

**TEAM (Notion+Claude):** workspace z baz odwzorowujących foldery (te same nazwy
pól co frontmatter) → relacje Spotkania→Konta, Decyzje→Procedury → konektor
Notion w Claude → te same 3 zapytania kontrolne → uprawnienia stron = strefy §5
Kontraktu (test z konta o ograniczonym dostępie).

**Sejf (LOCAL/DUAL):** Ollama + model PL na sprzęcie klienta → pomiar czasu
odpowiedzi (>30 s = rozmowa o sprzęcie PRZED podpisaniem) → izolacja zweryfikowana
na poziomie sieci, nie na słowo.

## Checklista odbioru (D10) — 14 pozycji

☐ struktura + Mapa Firmy startowa · ☐ 10 SOP z właścicielami i datami przeglądu ·
☐ 5 szablonów ze skrótu · ☐ widoki kontrolne zwracają poprawne wyniki ·
☐ AI odpowiada ze źródłem (3 testy) · ☐ zapis AI ograniczony do 02/05 ·
☐ strefy zgodne z Kontraktem · ☐ backup wykonany i ODTWORZONY · ☐ lint RODO
czysty · ☐ limit wydatków + alert na koncie AI · ☐ Kurator przeszkolony, rytuał
w kalendarzu · ☐ nagrania przekazane · ☐ baseline spisany · ☐ wersje w rejestrze

(Ta sama lista żyje w portalu — `cortex_state.ts` — i tam jest bramką odbioru.)

## Po wdrożeniu

Rytuał miesięczny Kuratora: skill `/przeglad-miesieczny` → raport → maks. 5 zadań.
Aktualizacje komponentów: wyłącznie po regresji na wzorcu (`testy-regresji/`),
w oknie serwisowym, z wpisem w rejestrze wersji wdrożenia.
