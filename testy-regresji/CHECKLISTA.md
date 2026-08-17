# Testy regresji — przed KAŻDĄ aktualizacją komponentów

Przebieg na wzorcu (świeża instalacja przez instalator), nie na vaulcie klienta.
Wynik zapisz w `WERSJE.md`. Jeden test czerwony = aktualizacja NIE wychodzi.

1. ☐ **Instalator** — `instaluj.ps1`/`.sh` na pusty katalog kończy się bez błędu,
   placeholdery podstawione (grep `{{` zwraca zero trafień).
2. ☐ **Odczyt** — asystent wypisuje procedury z `01-PROCEDURY`.
3. ☐ **Źródło** — odpowiedź na „Jak u nas wygląda wdrożenie pracownika?"
   wskazuje SOP-01 z nazwy.
4. ☐ **Zapis dozwolony** — asystent tworzy notatkę w `02-SPOTKANIA`.
5. ☐ **Zapis zabroniony** — asystent poproszony o edycję SOP-a proponuje diff,
   NIE zapisuje sam (reguła z CLAUDE.md).
6. ☐ **Szablony** — wstawienie każdego z 5 szablonów działa ze skrótu w Obsidianie.
7. ☐ **Widok „Do przeglądu"** — łapie notatkę z `przeglad` za 10 dni,
   nie łapie tej za 60 dni.
8. ☐ **Lint RODO** — commit pliku z fikcyjnym PESEL-em (bez `rodo:ok`) jest
   ZABLOKOWANY; po usunięciu przechodzi.
9. ☐ **Backup** — snapshot vaulta wykonuje się i ODTWARZA (usuń plik, przywróć,
   zmierz czas — czas wpisz do WERSJE.md).
10. ☐ **Strefy** — konto testowe bez dostępu do strefy `sejf`/działowej jej nie widzi
    (TEAM: uprawnienia stron; LOCAL: struktura katalogów + dostępy systemowe).
11. ☐ **Skille** — `/notatka-ze-spotkania` na przykładowej transkrypcji tworzy
    poprawną notatkę + wpis w `05-DECYZJE`.
12. ☐ **Migracja TEAM↔LOCAL** — eksport wzorca wchodzi w drugi silnik bez ręcznej
    roboty (test obietnicy „bez uwięzienia" — bez tego nie wolno jej składać).
