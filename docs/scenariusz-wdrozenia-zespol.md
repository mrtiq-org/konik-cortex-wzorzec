# Scenariusz wdrożenia: zespół 3 osób, ścieżka LOCAL, wspólny vault

Instrukcja dla operatora KONIK na dzień instalacji. Uzupełnia
[instalacja-macbook.md](instalacja-macbook.md) (pojedyncza maszyna) i
[runbook-wdrozenia.md](runbook-wdrozenia.md) (10 dni). Komendy są dla macOS;
odpowiedniki Windows w nawiasach. Zakładany czas: 2–2,5 h na trzy maszyny.

---

## A. Przed spotkaniem (Ty, dzień wcześniej)

| # | Co | Skąd wiesz, że zrobione |
|---|---|---|
| A1 | Kontrakt Danych podpisany | skan w teczce klienta; bez tego bramka 1 w portalu nie puści budowy |
| A2 | Konto klienta w portalu KONIK; spisane **ID konta** | przełącznik kont → wchodzisz na konto → Panel Klienta działa |
| A3 | W portalu: Drugi Mózg → **uruchom wdrożenie**, ścieżka **LOCAL**, kurator (imię + rola), przegląd za 30 dni | klient widzi 9 etapów na swoim koncie |
| A4 | Poświadczenie MCP: Konsola menadżera → MCP → **jeden klient, tryb read, 90 dni**, etykieta z nazwą firmy | sekret w Twoim menedżerze haseł (pokazuje się raz) |
| A5 | **Puste, prywatne repo git** na vault; trzy osoby jako współpracownicy | każda z nich potwierdziła, że ma konto i widzi repo |
| A6 | Ustalone z klientem: dostęp do repo z ich maszyn (SSH albo token HTTPS) | inaczej pierwszy push na spotkaniu stanie na haśle |
| A7 | Trzy konta Claude (po jednym na osobę) z **limitem wydatków** | klient potwierdza mailem; na spotkaniu tylko sprawdzasz |
| A8 | Repo wzorca wypchnięte na GitHub, regresja przeszła | `git status` czysty, `WERSJE.md` ma wpis |
| A9 | Wydrukowana checklista odbioru (14 pozycji, runbook) | do teczki |

Jeśli A1 lub A5 nie ma — instalacja idzie dalej (vault działa lokalnie), ale
bez pusha do wspólnego repo i bez odhaczenia etapu budowy. Powiedz to klientowi
wprost, nie udawaj, że wszystko wjechało.

---

## B. Na spotkaniu

### B1. Maszyna kuratora (ok. 40 min)

1. Otwórz terminal (Windows: PowerShell), sklonuj wzorzec:
   ```bash
   git clone https://github.com/mrtiq-org/konik-cortex-wzorzec.git ~/konik-wzorzec
   cd ~/konik-wzorzec
   ```
2. Zależności systemowe:
   ```bash
   ./instalator/przygotuj-maszyne.sh
   ```
   (Windows: `.\instalator\przygotuj-maszyne.ps1`). Na końcu skrypt wypisuje
   wersje Obsidiana i Claude — **zapisz je**, idą do portalu.
3. Ręcznie, przy kuratorze: uruchom **Claude Desktop** i zaloguj **jego** konto;
   sprawdź limit wydatków (A7); uruchom raz **Obsidian** (bez otwierania vaulta).
4. **Windows: otwórz nowe okno PowerShell** — świeży node nie jest w PATH starego.
5. Instalator z adresem wspólnego repo (A5):
   ```bash
   KONIK_REMOTE=git@github.com:firma/drugi-mozg.git ./instalator/instaluj.sh "Nazwa Firmy" ~/Drugi-Mozg "Imię Kuratora"
   ```
   (Windows: `.\instalator\instaluj.ps1 -Firma "…" -Cel "C:\Drugi-Mozg" -Kurator "…" -Remote "…"`).
   Na pytania podaj ID konta (A2) i token (A4). Token wpisujesz po cichu —
   nie wklejaj go jako argumentu.
   Musisz zobaczyć linię `wypchnięto do wspólnego repo`. Jeśli jej nie ma,
   push nie przeszedł — napraw dostęp (A6) ZANIM zaczniesz osoby 2 i 3.
6. Obsidian → *Open folder as vault* → `~/Drugi-Mozg`; Ustawienia → Templates
   → folder `08-SZABLONY`.
7. **Zrestartuj Claude Desktop** (serwery MCP wczytują się przy starcie).

### B2. Test przy kuratorze — na głos, przy wszystkich trzech osobach

| Test | Co mówisz / robisz | Co ma się stać |
|---|---|---|
| Portal | w Claude: „pokaż stan Drugiego Mózgu" | użyte narzędzie `drugi_mozg`, na ekranie 9 etapów z portalu |
| Źródło | „jak u nas wygląda wdrożenie nowego pracownika?" | odpowiedź wskazuje **SOP-01** z nazwy |
| RODO | w Obsidianie nowa notatka w `02-SPOTKANIA/2026` z treścią `PESEL: 44051401359`; w terminalu `git add -A && git commit -m test` | `Commit zablokowany: dane osobowe w vaulcie.` |

Po teście RODO usuń notatkę. Ten test pokazujesz wszystkim — to jest
Kontrakt Danych w praktyce, lepszy niż slajd.

### B3. Osoby 2 i 3 — równolegle (ok. 25 min każda)

1. Klon wzorca + `przygotuj-maszyne` jak w B1.1–B1.2; zapisz wersje.
2. Claude Desktop zalogowany na **własne** konto tej osoby; limit; jedno
   uruchomienie Obsidiana; Windows: nowe okno PowerShell.
3. Dołączenie do wspólnego repo:
   ```bash
   ./instalator/dolacz.sh git@github.com:firma/drugi-mozg.git ~/Drugi-Mozg "Imię Nazwisko"
   ```
   (Windows: `.\instalator\dolacz.ps1 -Remote "…" -Cel "C:\Drugi-Mozg" -Osoba "…"`).
   ID konta i token **te same, co u kuratora**. Skrypt sam sprawdza, że repo
   jest vaultem KONIK, dokłada hook RODO i tożsamość tej osoby w commitach.
4. Obsidian (vault + szablony) i restart Claude Desktop jak w B1.6–B1.7.
5. Test RODO z B2 — na tej maszynie, żeby osoba widziała, że blokada jest
   u niej, nie tylko u kuratora.

### B4. Próba synchronizacji (10 min) — dowód „jedna pamięć"

1. Osoba 2 w Claude: `/notatka-ze-spotkania` na dzisiejszym spotkaniu
   (2–3 zdania ustaleń, bez nazwisk — role zamiast osób).
2. Osoba 2 w terminalu vaulta:
   ```bash
   git add -A && git commit -m "Notatka z wdrożenia" && git push
   ```
3. Kurator: `git pull` → plik pojawia się w `02-SPOTKANIA/2026`; w historii
   widać autora **osobę 2**, nie kuratora.
4. Osoba 3: `git pull` → ma to samo.

### B5. Umowa rytmu pracy (5 min)

Powiedz wprost i pokaż sekcję **„Praca w zespole"** w
`00-START/Jak korzystać z systemu.md` (jest w każdym vaulcie z wzorca):
`pull` rano · `commit` + `push` po każdej sesji w Claude · konflikt rozstrzyga
kurator. Notatka tylko na jednej maszynie = notatka, której nie ma.

### B6. Portal przy kliencie (10 min)

Wejdź na konto klienta → Drugi Mózg: odhacz zrobione etapy (znacznik czasu
stawia serwer, nie Ty), wpisz **wersje komponentów** z trzech maszyn
(Obsidian, Claude Desktop, node), uzupełnij checklistę. Odbiór jest
zablokowany poniżej 14/14 — to bramka serwera, nie ozdoba. Pokaż klientowi,
że widzi to samo na swoim koncie.

### B7. Pierwsza lektura i termin (5 min)

`00-START/Jak korzystać z systemu.md` i `00-START/Kontrakt Danych.md` —
kurator czyta przy Tobie. Przegląd za **30 dni** w kalendarzu obu stron;
w tym samym rytmie odnowienie poświadczenia MCP (90 dni).

### B8. CRM — co mówisz

CRM to **etap 2** (osobna aplikacja, klucz per osoba). Do tego czasu w
`03-KONTA` Paszport konta dostaje wyłącznie identyfikator rekordu i link —
żadnych telefonów, maili, nazwisk. Kontrola RODO i tak by je zatrzymała.

---

## C. Czego NIE obiecujesz na tym spotkaniu

- Głosówki z portalu (migracje 099/101/102 na prod niepotwierdzone).
- Osobnych loginów do portalu KONIK dla trzech osób (klient = jedno konto).
- Telefonu dla ścieżki LOCAL (MCP działa tylko na desktopie).

## D. Co zostawiasz

Trzy klony jednego repo z hookiem RODO · Obsidian z szablonami · Claude Desktop
z `konik-mcp` (read-only) na każdej maszynie · wpis w portalu z wersjami ·
termin przeglądu · wydrukowana checklista z Twoimi odhaczeniami.
