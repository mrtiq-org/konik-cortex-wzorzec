# Rejestr wersji komponentów (§10 Kontraktu Danych)

Aktualizacja czegokolwiek bez wpisu tutaj = brak aktualizacji.
Wpis dopiero PO pełnym przebiegu `testy-regresji/CHECKLISTA.md` na wzorcu.

| Komponent | Wersja zamrożona | Data testu regresji | Kto testował | Uwagi |
|---|---|---|---|---|
| Obsidian | — do ustalenia przy pierwszej instalacji | | | |
| Claude Desktop | — | | | |
| Claude Code | — | | | |
| Serwer MCP (plikowy) | — | | | preferowany zamiast wtyczek Obsidiana |
| Ollama + model PL (Sejf) | — | | | tylko ścieżki LOCAL/DUAL |
| Instalator wzorca (instaluj / dolacz / przygotuj-maszyne) | commit z 2026-09-03 | 2026-09-03 | Claude (sesja CTO) | **Przebieg CZĘŚCIOWY**: testy 1 i 8 + synchronizacja dwóch maszyn przez bare repo — zielone, mutacja hooka potwierdzona. Testy 2–7 i 9–12 wymagają Obsidiana/Claude Desktop — NIE wykonane. `przygotuj-maszyne.ps1` bez pełnego przebiegu z instalacją pakietów. |

Historia zmian: prowadzona commitami tego pliku (git log -- WERSJE.md).
