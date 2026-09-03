---
typ: wiedza
tytul: Jak korzystać z systemu
wlasciciel: Kurator Wiedzy
status: obowiazuje
utworzono: {{data}}
wersja: "1.0"
strefa: ogolna
tagi: [start]
---

# Jak korzystać z Drugiego Mózgu

## Trzy zasady, które wystarczą na start

1. **Najpierw pytaj, potem szukaj.** Asystent AI zna całą bazę — zapytaj
   „Jak u nas wygląda ___?" i zawsze sprawdź podane źródło.
2. **Jedno miejsce zapisu.** Wiedza (procedury, ustalenia, know-how) żyje TUTAJ.
   Klienci, zadania i dane osobowe żyją w CRM. Pliki źródłowe na dysku firmowym —
   tu tylko link. Jeśli nie wiesz, gdzie coś zapisać → [[Kontrakt Danych]].
3. **Notatka bez frontmattera nie istnieje dla systemu.** Zaczynaj od szablonu
   (`08-SZABLONY`), nie od pustej kartki.

## Nazewnictwo

- Procedury: `SOP-03 Obsługa zapytania ofertowego`
- Spotkania: `2026-08-12 Spotkanie — Cemet` (data zawsze z przodu)
- Konta firm: `KONTO Cemet` — kontekst relacji z FIRMĄ, nigdy dane osób

## Czego tu NIE wolno wpisywać

Danych osobowych: numerów PESEL, prywatnych telefonów, adresów e-mail osób.
Kontakt do człowieka trzymamy w CRM i wpisujemy tu tylko `crm_id`.
System sam pilnuje tej zasady (kontrola przy każdym zapisie) — ale to Ty
odpowiadasz za to, co wklejasz.

## Praca w zespole — jedna pamięć, nie trzy

Baza jest wspólna: każda osoba ma kopię na swoim komputerze, a łączy je
repozytorium git. Trzy nawyki, bez których kopie się rozjadą:

1. **Rano `pull`** — zanim zaczniesz, ściągasz to, co dopisali inni.
2. **Po sesji `commit` + `push`** — to, co dopisałeś z asystentem, idzie do
   zespołu tego samego dnia. Notatka tylko u Ciebie = notatka, której nie ma.
3. **Konflikt na tym samym pliku rozstrzyga Kurator Wiedzy.** Nie nadpisuj
   cudzej wersji, zgłoś, kurator scala.

Kontrola danych osobowych działa przy każdym `commit` na każdym komputerze —
wpis z PESEL-em czy prywatnym telefonem nie wyjdzie z Twojej maszyny.

## Kto opiekuje się bazą

Kurator Wiedzy: **{{KURATOR}}**. Do niego zgłaszasz nieaktualne procedury
i propozycje zmian. Przegląd bazy odbywa się raz w miesiącu.
