# Instalacja u klienta na MacBooku — Obsidian + Claude + portal KONIK

Instrukcja dla operatora KONIK, nie dla klienta. Czas: ~20 min z instalacją
Obsidiana i Claude Desktop, których i tak nie da się zautomatyzować (logowanie
na konta klienta).

---

## 0. Zanim usiądziesz przy jego komputerze

Na MacBooku klienta muszą być:

| Co | Skąd | Sprawdzenie |
|---|---|---|
| Node.js 18+ | nodejs.org (LTS) | `node -v` |
| git | `xcode-select --install` | `git --version` |
| Obsidian | obsidian.md | uruchamia się |
| Claude Desktop | claude.ai/download | klient jest **zalogowany na swoje konto** |

Cztery pierwsze pozycje stawia jeden skrypt (Homebrew na Macu, winget na
Windowsie); zainstalowane pomija, na końcu wypisuje wersje do wpisania w portalu:

```bash
./instalator/przygotuj-maszyne.sh        # macOS
.\instalator\przygotuj-maszyne.ps1       # Windows (PowerShell)
```

Wymaga zainstalowanego Homebrew (Mac) albo wbudowanego winget (Windows 10/11).
Logowania do Claude Desktop, limitu wydatków i otwarcia vaulta w Obsidianie
skrypt nie zrobi — to zostaje człowiekowi i skrypt mówi o tym na końcu.
Na Windowsie po skrypcie otwórz **nowe** okno PowerShell: świeży node/git nie
jest w PATH bieżącej sesji.

Konto AI klienta musi mieć **ustawiony limit wydatków i alert** — to punkt
z checklisty odbioru, robimy go PRZED pierwszym użyciem, nie po.

---

## 1. Vault + serwer MCP — jedna komenda

```bash
git clone https://github.com/mrtiq-org/konik-cortex-wzorzec.git ~/konik-wzorzec
cd ~/konik-wzorzec
chmod +x instalator/instaluj.sh
./instalator/instaluj.sh "Nazwa Firmy Klienta" ~/Drugi-Mozg "Imie Kuratora"
```

Instalator przeprowadza 6 kroków: kopiuje wzorzec, podstawia nazwę firmy
i kuratora, sprawdza czy nie ma danych osobowych, zakłada gita z hookiem
blokującym commit z PESEL-em/telefonem/mailem, stawia serwer MCP
w `~/.konik/konik-mcp` i wpina go do Claude Desktop.

Na końcu zapyta o **ID konta** i **token** klienta (skąd — punkt 3). Możesz
wcisnąć Enter i uzupełnić później: instalator powie wtedy wprost, że
połączenia z portalem jeszcze nie ma, i skończy się kodem 3 zamiast „Gotowe".

### 1a. Kilka osób w firmie — jeden wspólny vault

Zespół = **jedno repo git, klon na każdej maszynie**. Nie uruchamiaj
`instaluj.sh` trzy razy — powstałyby trzy osobne vaulty o tej samej nazwie.

1. Załóż **puste, prywatne** repo (konto klienta na GitHub/GitLab albo nasz
   GitLab z umową powierzenia) i dodaj wszystkie osoby jako współpracowników.
2. **Maszyna kuratora**: instalator z adresem repo — commit startowy idzie od
   razu tam:

```bash
KONIK_REMOTE=git@github.com:firma/drugi-mozg.git ./instalator/instaluj.sh "Nazwa Firmy" ~/Drugi-Mozg "Imię Kuratora"
```

3. **Każda kolejna osoba**: `dolacz.sh` klonuje wspólne repo i dokłada to,
   czego clone nie przenosi — hook RODO (git nie wersjonuje `.git/hooks`),
   tożsamość tej osoby w commitach, serwer MCP, wpis w Claude Desktop:

```bash
./instalator/dolacz.sh git@github.com:firma/drugi-mozg.git ~/Drugi-Mozg "Jan Kowalski"
```

   Windows: `.\instalator\dolacz.ps1 -Remote … -Cel … -Osoba …`. ID konta
   i token są **te same** co u kuratora (jedno poświadczenie na wdrożenie).
   Skrypt odmawia, gdy repo nie jest vaultem KONIK, i sprząta po sobie.
4. Rytm pracy, który mówisz zespołowi: `git pull` rano, commit + push po
   sesji w Claude. Konflikt na tym samym pliku rozstrzyga kurator.

Sprawdzone end-to-end na lokalnym repo (2026-09-03): commit z PESEL-em u osoby
dołączonej jest blokowany, czysta notatka po pushu widoczna u kuratora.

Katalog `~/konik-wzorzec` po instalacji nie jest już potrzebny — serwer MCP
mieszka osobno w `~/.konik`. Zostaw go jednak, żeby dało się zaktualizować
wzorzec bez klonowania od nowa.

---

## 2. Obsidian — 3 kliknięcia

1. *Open folder as vault* → wskaż `~/Drugi-Mozg`
2. Ustawienia → **Templates** → włącz → folder: `08-SZABLONY`
3. Pokaż klientowi `00-START/Jak korzystać z systemu.md` — to jego pierwsza lektura

---

## 3. Połączenie z portalem KONIK

Serwer MCP daje Claude'owi klienta **odczyt jego portalu**: co czeka na
akceptację, kalendarz publikacji, dokumenty marki, stan wdrożenia Drugiego
Mózgu. Nic nie zapisuje — akceptacje zostają w portalu.

Potrzebne dwie wartości:

- `KONIK_CLIENT_ID` — UUID konta klienta w KONIKU
- `KONIK_TOKEN` — **poświadczenie agentowe** `konik_agt_…`

Poświadczenie wydajesz sobie sam, ze swojego konta menadżera:

> **Konsola menadżera → zakładka MCP → Wydaj poświadczenie**
> - *Klienci w zakresie*: TYLKO ten jeden klient
> - *Tryb*: **read** — Claude klienta ma czytać jego portal, nie zmieniać konta
> - *Ważność*: do 90 dni
> - *Etykieta*: np. „MacBook Anny, Cemet"

Sekret pokazuje się **raz**. Backend rozpoznaje go po prefiksie `konik_agt_`
i idzie ścieżką agentową zamiast sesyjnego JWT — `konik-mcp` przyjmuje go
jako `KONIK_TOKEN` bez żadnej zmiany.

Czego to poświadczenie NIE jest: nie jest kluczem klienta. Właścicielem jesteś
Ty, więc przestaje działać, gdy Twoje konto w zespole KONIK zostanie wyłączone.
Wygasa najpóźniej po 90 dniach — odnowienie wpada w rytm przeglądu.
Unieważnisz je w tej samej zakładce, natychmiast, bez ruszania maszyny klienta.

Instalator wpisze obie wartości do konfiguracji Claude Desktop. Jeśli robisz to
później, ręcznie:

```bash
node ~/konik-wzorzec/narzedzia/rejestruj-mcp.js \
  ~/Library/Application\ Support/Claude/claude_desktop_config.json \
  ~/.konik/konik-mcp/index.js \
  https://dev.koniksystems.com \
  "<client-id>" "<token>"
```

Skrypt **scala** konfigurację — inne serwery MCP klienta zostają nietknięte,
a plik dostaje kopię zapasową z datą.

### Czego NIE wklejać

Tokenu sesji z portalu (`access_token` z Local Storage przeglądarki). Żyje
około godziny i odświeża go wyłącznie przeglądarka — serwer MCP nie ma jak go
odnowić, więc połączenie umrze tego samego dnia. Do vaulta idzie wyłącznie
poświadczenie `konik_agt_…`.

### Czego NIE mylić z tym serwerem

Modal po wydaniu poświadczenia podpowiada komendę
`claude mcp add … https://mcp.koniksystems.com/mcp`. To **inny serwer**:
proxy dla zespołu KONIK (strategia, dokumenty marki, korekty), używane przez
opiekuna w jego własnym Claude. Klient dostaje lokalny `konik-mcp` po stdio,
z pięcioma narzędziami tylko do odczytu jego portalu.

### Gdy klienta nie ma jeszcze w portalu

Zainstaluj sam vault: `KONIK_SKIP_MCP=1 ./instalator/instaluj.sh …`.
Obsidian i Claude na procedurach działają w pełni bez połączenia — MCP
dołożysz jednym uruchomieniem `rejestruj-mcp.js`, gdy konto powstanie.

---

## 4. Sprawdzenie, że żyje

1. **Zrestartuj Claude Desktop** — serwery MCP wczytują się przy starcie
2. W Claude: *„pokaż stan Drugiego Mózgu"* → powinno użyć narzędzia `drugi_mozg`
   i pokazać etapy wdrożenia z portalu
3. W Claude (na katalogu vaulta): *„jaka jest procedura wdrożenia nowego
   pracownika?"* → odpowiedź z `SOP-01`
4. Spróbuj commita z PESEL-em w notatce → hook musi zablokować

Punkt 4 pokaż klientowi. To jest moment, w którym rozumie, czym jest kontrakt
danych — lepiej niż jakikolwiek slajd.

---

---

## 4a. Strona KONIKA — wdrożenie musi istnieć w panelu

Sam vault to połowa produktu. Druga połowa to wdrożenie prowadzone w portalu,
które klient WIDZI u siebie:

1. Zaloguj się jako menadżer → przełącznik kont w bocznym pasku → **wejdź na
   konto klienta** (klient musi mieć konto w portalu KONIK)
2. Panel Klienta → **Drugi Mózg** → uruchom wdrożenie → ścieżka **LOCAL**
   (vault na MacBooku klienta = dane nie opuszczają jego biura)
3. Wpisz **kuratora wiedzy** (imię + rola) i **datę przeglądu po 30 dniach**
4. Wpisz **wersje komponentów** — Obsidian i Claude Desktop z tej maszyny
5. Odhaczaj etapy w miarę postępu. Odbiór systemu jest **zablokowany**, dopóki
   checklista nie ma 14/14 — to bramka po stronie serwera, nie ozdoba

Klient widzi wszystkie 9 etapów i checklistę na swoim koncie. Przejrzystość
procesu jest częścią produktu — nie ma tu trybu „pokażemy na końcu".

---

## 5. Co zostawiasz klientowi

- vault w `~/Drugi-Mozg` (git, historia od dnia wdrożenia)
- Obsidian z szablonami
- Claude Desktop widzący vault i (warunkowo) portal
- `00-START/Kontrakt Danych.md` — co wolno wpisywać, czego nie
- termin przeglądu po 30 dniach

## Odinstalowanie

```bash
rm -rf ~/.konik/konik-mcp
```

plus usunięcie wpisu `konik-portal` z konfiguracji Claude Desktop. Vault
zostaje — to własność klienta, nie nasza instalacja.
