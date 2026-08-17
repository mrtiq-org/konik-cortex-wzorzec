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

Potrzebne dwie wartości z zalogowanej sesji klienta w portalu:

- `KONIK_CLIENT_ID` — identyfikator konta (`user.id` z sesji)
- `KONIK_TOKEN` — token dostępu (`access_token` z sesji)

**Panel ich dziś NIE pokazuje.** Trzeba je wyjąć z narzędzi deweloperskich
przeglądarki: zalogowany portal → *Application* → *Local Storage* → wpis
`sb-…-auth-token` → w JSON-ie `access_token` i `user.id`.

Instalator wpisze je do konfiguracji Claude Desktop. Jeśli robisz to później,
ręcznie:

```bash
node ~/konik-wzorzec/narzedzia/rejestruj-mcp.js \
  ~/Library/Application\ Support/Claude/claude_desktop_config.json \
  ~/.konik/konik-mcp/index.js \
  https://dev.koniksystems.com \
  "<client-id>" "<token>"
```

Skrypt **scala** konfigurację — inne serwery MCP klienta zostają nietknięte,
a plik dostaje kopię zapasową z datą.

### ⚠️ To połączenie jest dziś DEMONSTRACYJNE

`access_token` z portalu to token sesji przeglądarki. W standardowej
konfiguracji Supabase żyje **około godziny**, a odświeża go wyłącznie
przeglądarka — serwer MCP nie ma jak go odnowić.

Praktycznie: połączenie działa na warsztacie i na pokazie, a po godzinie
narzędzia zaczynają zwracać „Sesja KONIK wygasła — zaloguj się w portalu
i zaktualizuj KONIK_TOKEN". Komunikat jest czytelny (nie ciche pustki), ale
klient nie będzie codziennie kopiował tokenu z devtoolsów.

**Do trwałego wdrożenia potrzebny jest długowieczny klucz per klient wydawany
z panelu — to otwarta decyzja 6 z CORTEX-PLAN.md, nie jest zbudowana.**

Dlatego przy wdrożeniu, w którym połączenie z portalem ma po prostu działać:
zainstaluj sam vault (`KONIK_SKIP_MCP=1`), a MCP dołóż, gdy klucz będzie
gotowy. Vault, Obsidian i Claude na procedurach działają bez tego w pełni.

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
