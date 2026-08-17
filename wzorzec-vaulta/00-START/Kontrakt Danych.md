---
typ: wiedza
tytul: Kontrakt Danych — wyciąg dla zespołu
wlasciciel: Kurator Wiedzy
status: obowiazuje
utworzono: {{data}}
wersja: "1.0"
strefa: ogolna
tagi: [start, zasady]
---

# Kontrakt Danych — gdzie co zapisujemy

Pełna wersja podpisana przez zarząd leży u Kuratora. To jest wyciąg roboczy.

| Co | Gdzie | Uwagi |
|---|---|---|
| SOP, procedury, instrukcje | **Vault** `01-PROCEDURY` | właściciel + data przeglądu |
| Decyzje i ustalenia ze spotkań | **Vault** `02-SPOTKANIA` / `05-DECYZJE` | z transkrypcji |
| Know-how, wygrane oferty, case studies, ton głosu | **Vault** `06-WIEDZA` | |
| Klienci, kontakty, deale, etapy | **CRM** | nigdy w vaulcie |
| Zadania i terminy | **CRM** | |
| Dane osobowe (klienci, pracownicy, kandydaci) | **CRM** | |
| Umowy, faktury, pliki źródłowe | **Dysk firmowy** | w vaulcie tylko link |
| Dane wrażliwe / tajemnica zawodowa | **Sejf lokalny** | model lokalny, bez chmury |

**Zasada nadrzędna: dane osobowe nie wchodzą do vaulta. Nigdy.**
Zamiast „Jan Kowalski, tel. 501…" wpisujemy `crm_id: 4471` i rolę
(„decydent techniczny — preferuje konkret"). Kontakt jest w CRM, wiedza tutaj.

Jeśli ta sama informacja leży w dwóch miejscach — to błąd. Zgłoś Kuratorowi.
