#!/usr/bin/env bash
# ============================================
# KONIK Cortex · przygotowanie maszyny (macOS)
#
# Krok ZERO przed instaluj.sh: stawia to, czego instalator vaulta wymaga,
# a czego sam nie instaluje — Node.js, git, Obsidian, Claude Desktop.
# Źródło: Homebrew (formuły node/git, caski obsidian/claude).
#
# Użycie:
#   ./przygotuj-maszyne.sh
#
# Wersje: Homebrew instaluje NAJNOWSZE i nie umie przypiąć wersji caska tak,
# jak winget na Windowsie. Dlatego skrypt na końcu WYPISUJE zainstalowane
# wersje — operator wpisuje je w portalu (wersje komponentów) i porównuje
# z WERSJE.md; rozjazd między trzema maszynami jednego klienta ma być widoczny,
# nie ukryty.
#
# Czego skrypt NIE robi, bo nie może: nie loguje Claude Desktop na konto osoby,
# nie ustawia limitu wydatków, nie otwiera vaulta w Obsidianie. Wypisuje to
# na końcu jako kroki dla człowieka.
#
# Linux: Claude Desktop nie ma oficjalnej wersji, więc skrypt kończy się tam
# jasnym komunikatem zamiast udawać, że przygotował maszynę.
# Idempotentny: zainstalowany pakiet pomija.
# ============================================
set -uo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Ten skrypt obsługuje macOS. Na Linuksie Claude Desktop nie ma oficjalnej wersji —"
  echo "ścieżka LOCAL na Linuksie to Claude Code (npm i -g @anthropic-ai/claude-code),"
  echo "Obsidian z flatpak/AppImage, node+git z menedżera pakietów. Zrób to ręcznie"
  echo "i uruchom instaluj.sh; instalator sam sprawdza obecność node."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  # Instalator Homebrew pyta o hasło administratora i jest interaktywny —
  # uruchamia go operator, nie ten skrypt, żeby było widać, na co się zgadza.
  echo "!! Brak Homebrew. Zainstaluj go oficjalną komendą z https://brew.sh, potem uruchom ponownie:"
  echo '   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

bledy=()

# formuła|cask  nazwa  pakiet
pakiety=(
  "formula|Node.js|node"
  "formula|git|git"
  # Bez tego git na Macu przy pushu po HTTPS pyta o haslo i odrzuca haslo do
  # GitHuba (wymaga tokenu). Z menedzerem otwiera okno logowania w przegladarce,
  # tak samo jak Git for Windows — jedna instrukcja dla obu systemow.
  "cask|Git Credential Manager|git-credential-manager"
  "cask|Obsidian|obsidian"
  "cask|Claude Desktop|claude"
)

i=0
for wpis in "${pakiety[@]}"; do
  i=$((i + 1))
  IFS='|' read -r rodzaj nazwa pakiet <<< "$wpis"
  etykieta="[$i/${#pakiety[@]}] $nazwa"
  if [ "$rodzaj" = "cask" ]; then
    if brew list --cask "$pakiet" >/dev/null 2>&1; then echo "$etykieta — już jest, pomijam"; continue; fi
    echo "$etykieta — instaluję (cask $pakiet)"
    brew install --cask "$pakiet" || bledy+=("$nazwa")
  else
    if brew list --formula "$pakiet" >/dev/null 2>&1; then echo "$etykieta — już jest, pomijam"; continue; fi
    echo "$etykieta — instaluję ($pakiet)"
    brew install "$pakiet" || bledy+=("$nazwa")
  fi
done

echo
echo "Weryfikacja:"
if command -v node >/dev/null 2>&1; then
  v="$(node -v)"; major="${v#v}"; major="${major%%.*}"
  if [ "$major" -ge 18 ]; then echo "  node    ${v#v}"
  else echo "  node    ${v#v} — ZA STARY, instalator wymaga 18+"; bledy+=("node < 18"); fi
else
  echo "  node    BRAK w PATH"; bledy+=("node nie widoczny")
fi
if command -v git >/dev/null 2>&1; then echo "  git     $(git --version | sed 's/git version //')"
else echo "  git     BRAK w PATH"; bledy+=("git nie widoczny"); fi

# Wersje aplikacji z Info.plist — to one idą do portalu i WERSJE.md.
wersja_app() {
  local plist="/Applications/$1.app/Contents/Info.plist"
  [ -f "$plist" ] && /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist" 2>/dev/null
}
command -v git-credential-manager >/dev/null 2>&1 && echo "  git-credential-manager  $(git-credential-manager --version 2>/dev/null | head -1)" || { echo "  git-credential-manager  BRAK — push po HTTPS bedzie pytal o token"; bledy+=("git-credential-manager"); }
for app in Obsidian Claude; do
  w="$(wersja_app "$app")"
  if [ -n "$w" ]; then echo "  $app  $w"; else echo "  $app  nie znaleziono w /Applications"; bledy+=("$app nie widoczny"); fi
done

echo
if [ "${#bledy[@]}" -gt 0 ]; then
  echo "Nie wszystko się udało: ${bledy[*]}."
  echo "Popraw powyższe i uruchom skrypt ponownie — zainstalowane pakiety pominie."
  exit 1
fi

echo "Maszyna gotowa pod instaluj.sh."
echo
echo "Zostaje człowiekowi (skrypt tego nie zrobi):"
echo "  1. Uruchom Claude Desktop i zaloguj tę osobę na JEJ konto"
echo "  2. Konto AI: limit wydatków + alert — PRZED pierwszym użyciem"
echo "  3. Uruchom Obsidian raz (pierwsze uruchomienie tworzy konfigurację)"
echo "  4. Odpal instaluj.sh"
