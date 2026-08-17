# Kontrakt Danych · v0.1 DRAFT — wymaga przeglądu prawnego przed pierwszym podpisem

Najważniejszy artefakt wdrożenia. Klient podpisuje w dniu 3 — **bez podpisu
nie ma budowy** (bramka 1 procesu). Kopia robocza §4/§6 trafia do vaulta
(`00-START/Kontrakt Danych.md`), żeby zasady były na wyciągnięcie ręki.

## §1 Cel

Każdy typ informacji ma dokładnie JEDNO miejsce zapisu. Reszta systemów to
interfejsy, które je czytają. Duplikat = błąd do zgłoszenia Kuratorowi.

## §2 Strony i role

- **Klient:** właściciel danych i treści; wskazuje imiennie Kuratora Wiedzy.
- **KONIK:** budowa i utrzymanie systemu; procesor wyłącznie w zakresie opisanym
  w umowie powierzenia (załącznik).
- **Kurator Wiedzy:** osoba klienta odpowiedzialna za aktualność bazy i rytuał
  przeglądu (miesięcznie).

## §3 Mapa zapisu (tabela nadrzędna)

| Co | Gdzie | Uwagi |
|---|---|---|
| SOP, procedury, instrukcje | Vault | właściciel + data przeglądu |
| Decyzje i ustalenia ze spotkań | Vault | z transkrypcji |
| Know-how, wygrane oferty, case studies, ton głosu | Vault | zasila moduły KONIK |
| Klienci, kontakty, deale, etapy | CRM klienta¹ | nigdy w vaulcie |
| Zadania i terminy | CRM klienta¹ | |
| Dane osobowe (klienci, pracownicy, kandydaci) | CRM klienta¹ | RoPA, retencja, DSR po stronie systemu CRM |
| Umowy, faktury, pliki źródłowe | Dysk klienta | w vaulcie tylko link |
| Dane wrażliwe / tajemnica zawodowa | Sejf lokalny (DUAL/LOCAL) | model lokalny, zero API zewnętrznych |

¹ Decyzja przejściowa 2026-08-08: do czasu zamknięcia RODO-sprintu platformy
KONIK dane osobowe kierujemy do CRM-u, którego klient już używa. CRM KONIK
wchodzi jako rozszerzenie po osiągnięciu zgodności (DECISIONS 2026-08-08).

## §4 Zasada nadrzędna

**Dane osobowe nie wchodzą do vaulta. Nigdy.** Zamiast osoby: `crm_id` + rola
+ styl współpracy. Egzekwowane automatycznie (lint: PESEL / e-mail / telefon
blokuje zapis; wyjątek `rodo:ok` wyłącznie dla danych fikcyjnych).

## §5 Strefy dostępu

`ogolna` (cały zespół) · `dzialowa` (per zespół) · `sejf` (zarząd/finanse,
wyłącznie lokalnie). Strefa jest polem frontmattera i uprawnieniem w silniku;
przeniesienie notatki między strefami wymaga zgody Kuratora.

## §6 Backup i wyjście

LOCAL: snapshot dzienny na dysk klienta + kopia tygodniowa off-site, wersjonowanie.
TEAM: eksport workspace co tydzień do archiwum klienta. Test odtworzenia przy
odbiorze i przy każdym audycie kwartalnym. Wyjście: klient zabiera pliki w 7 dni,
KONIK usuwa dostępy w 14.

## §7 Wersje komponentów

Zamrożone. Aktualizacja wyłącznie po przebiegu regresji na wzorcu KONIK,
w oknie serwisowym, z wpisem do rejestru wersji (`WERSJE.md` wdrożenia).
Aktualizacja bez wpisu = naruszenie kontraktu serwisowego.

## §8 Podpisy

Klient (zarząd) · Kurator Wiedzy · KONIK (opiekun wdrożenia) · data.
