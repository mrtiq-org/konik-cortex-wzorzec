#!/usr/bin/env bash
# ============================================
# KONIK Cortex · bootstrap (macOS) — jedna linia zamiast ośmiu kroków.
#
#   /bin/bash -c "$(curl -fsSL https://dev.koniksystems.com/cortex/instaluj)"
#
# Ta forma (nie `curl | bash`) jest celowa: bash najpierw POBIERA cały skrypt,
# a dopiero potem go wykonuje — stdin zostaje terminalem, więc pytania
# o nazwę firmy czy token działają normalnie. Przy `curl | bash` stdin to
# strumień skryptu i pierwszy `read` zjadłby resztę pliku.
#
# Co robi, bez Homebrew i bez gita:
#   1. Node LTS  — oficjalny .pkg z nodejs.org (pyta o hasło administratora)
#   2. Obsidian  — oficjalny .dmg z GitHuba obsidianmd
#   3. Claude    — oficjalny .zip z downloads.claude.ai
#   4. wzorzec   — wzorzec.zip z naszej domeny → ~/.konik/wzorzec
#   5. instaluj.sh z tego wzorca (vault, RODO, git, MCP, Claude Desktop)
#   6. otwiera vault w Obsidianie (obsidian://)
#
# Adresy Obsidiana i Claude'a bierzemy w locie z API Homebrew
# (formulae.brew.sh) — NIE instalując Homebrew. Ich opiekunowie aktualizują
# te adresy przy każdym wydaniu, a my nie musimy wypuszczać nowej wersji
# bootstrapa za każdym razem, gdy Anthropic zmieni hash w nazwie pliku.
#
# Zainstalowane pomija. Bezpieczne do ponownego uruchomienia.
# Nie robi: logowania do Claude'a, limitu wydatków, poświadczenia z panelu.
# ============================================
set -euo pipefail

BASE="${KONIK_CORTEX_BASE:-https://dev.koniksystems.com/cortex}"
KONIK_HOME="${KONIK_HOME:-$HOME/.konik}"
WZORZEC_DIR="$KONIK_HOME/wzorzec"
TMP="$(mktemp -d -t konik-cortex)"
trap 'rm -rf "$TMP"' EXIT

krok()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
uwaga() { printf '\033[33m!! %s\033[0m\n' "$*"; }
stop()  { printf '\033[31mSTOP: %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || stop "Ten bootstrap jest dla macOS. Windows: irm $BASE/instaluj.ps1 | iex"

# Adres z API Homebrew; pierwszy `url` w JSON-ie caska to zawsze build na
# macOS (AppImage'e dla Linuksa są dalej). Bez jq — grep wystarcza.
url_caska() {
  curl -fsSL "https://formulae.brew.sh/api/cask/$1.json" \
    | grep -oE '"url":"[^"]*"' | head -1 | sed 's/"url":"//;s/"$//'
}

# .dmg → montuj, kopiuj .app; .zip → rozpakuj, przenieś .app.
zainstaluj_app() {
  local nazwa="$1" cask="$2" app="/Applications/$1.app" url src mnt
  if [ -d "$app" ]; then echo "  jest: $app"; return 0; fi
  url="$(url_caska "$cask")"
  if [ -z "$url" ]; then
    uwaga "Nie udało się ustalić adresu pobierania $nazwa — zainstaluj ręcznie i uruchom ponownie."
    return 1
  fi
  echo "  pobieram ${url##*/}"
  case "$url" in
    *.dmg)
      curl -fL --progress-bar "$url" -o "$TMP/$cask.dmg"
      mnt="$TMP/mnt-$cask"; mkdir -p "$mnt"
      hdiutil attach -nobrowse -quiet -mountpoint "$mnt" "$TMP/$cask.dmg"
      src="$(find "$mnt" -maxdepth 1 -name '*.app' | head -1)"
      if [ -z "$src" ]; then hdiutil detach -quiet "$mnt"; uwaga "W obrazie $nazwa nie ma .app"; return 1; fi
      cp -R "$src" /Applications/
      hdiutil detach -quiet "$mnt"
      ;;
    *.zip)
      curl -fL --progress-bar "$url" -o "$TMP/$cask.zip"
      mkdir -p "$TMP/unz-$cask"
      ditto -x -k "$TMP/$cask.zip" "$TMP/unz-$cask"
      src="$(find "$TMP/unz-$cask" -maxdepth 2 -name '*.app' | head -1)"
      if [ -z "$src" ]; then uwaga "W archiwum $nazwa nie ma .app"; return 1; fi
      mv "$src" /Applications/
      ;;
    *) uwaga "Nieznany format pobierania $nazwa: $url"; return 1 ;;
  esac
  if [ -d "$app" ]; then echo "  gotowe: $app"; else uwaga "$nazwa nie wylądował w /Applications"; return 1; fi
}

wersja_app() {
  defaults read "/Applications/$1.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo '?'
}

# Cały przebieg siedzi w main(): gdyby ktoś jednak użył `curl | bash`, bash
# ma funkcję sparsowaną w całości, zanim przekierujemy stdin na /dev/tty —
# więc przekierowanie nie zje reszty pliku.
main() {
  local bledy=() rc=0 pkg inner root FIRMA KURATOR CEL

  if [ ! -t 0 ]; then
    [ -r /dev/tty ] || stop "Brak terminala do zadawania pytań. Uruchom: /bin/bash -c \"\$(curl -fsSL $BASE/instaluj)\""
    exec </dev/tty
  fi
  command -v curl >/dev/null || stop "Brak curl (jest w każdym macOS — coś jest bardzo nie tak)."

  # Prawa do /Applications: administrator ma je z pudełka, konto standardowe
  # nie. Sprawdzamy raz, zamiast wykładać się na drugim kroku.
  [ -w /Applications ] || stop "Konto $(whoami) nie może pisać do /Applications — zaloguj się na konto administratora tego Maca."

  # ─── 1. Node ────────────────────────────────────────────────────────────────
  krok "[1/6] Node.js"
  if command -v node >/dev/null 2>&1 && [ "$(node -v | sed 's/^v//;s/\..*//')" -ge 18 ]; then
    echo "  jest: $(node -v)"
  else
    pkg="$(curl -fsSL https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt | grep -oE 'node-v[0-9.]+\.pkg' | head -1)"
    [ -n "$pkg" ] || stop "Nie udało się ustalić wersji Node z nodejs.org."
    echo "  pobieram $pkg"
    curl -fL --progress-bar "https://nodejs.org/dist/latest-v22.x/$pkg" -o "$TMP/node.pkg"
    echo "  instaluję — macOS zapyta o hasło administratora"
    sudo installer -pkg "$TMP/node.pkg" -target / >/dev/null
    export PATH="/usr/local/bin:$PATH"
    command -v node >/dev/null || stop "Node zainstalowany, ale nie ma go w PATH. Otwórz nowy terminal i uruchom ponownie."
    echo "  gotowe: $(node -v)"
  fi

  # ─── 2-3. aplikacje ─────────────────────────────────────────────────────────
  krok "[2/6] Obsidian";       zainstaluj_app Obsidian obsidian || bledy+=("Obsidian")
  krok "[3/6] Claude Desktop"; zainstaluj_app Claude claude     || bledy+=("Claude Desktop")

  # ─── 4. wzorzec ─────────────────────────────────────────────────────────────
  krok "[4/6] Wzorzec vaulta"
  curl -fsSL "$BASE/wzorzec.zip" -o "$TMP/wzorzec.zip" || stop "Nie udało się pobrać $BASE/wzorzec.zip"
  rm -rf "$WZORZEC_DIR"; mkdir -p "$WZORZEC_DIR"
  ditto -x -k "$TMP/wzorzec.zip" "$WZORZEC_DIR"
  # ZIP może mieć jeden katalog nadrzędny — spłaszczamy, żeby instalator był
  # tam, gdzie go szukamy.
  if [ ! -f "$WZORZEC_DIR/instalator/instaluj.sh" ]; then
    inner="$(find "$WZORZEC_DIR" -maxdepth 3 -name instaluj.sh -path '*/instalator/*' | head -1)"
    [ -n "$inner" ] || stop "W wzorzec.zip nie ma instalator/instaluj.sh"
    root="$(cd "$(dirname "$inner")/.." && pwd)"
    ditto "$root" "$TMP/flat" && rm -rf "$WZORZEC_DIR" && mv "$TMP/flat" "$WZORZEC_DIR"
  fi
  chmod +x "$WZORZEC_DIR"/instalator/*.sh
  echo "  $WZORZEC_DIR"

  if [ "${#bledy[@]}" -gt 0 ]; then
    uwaga "Nie zainstalowano: ${bledy[*]}. Vault i tak powstanie — dokończ to ręcznie przed oddaniem klientowi."
  fi

  # ─── 5. instalator ──────────────────────────────────────────────────────────
  krok "[5/6] Vault + serwer MCP"
  printf 'Nazwa firmy klienta: '; read -r FIRMA
  [ -n "$FIRMA" ] || stop "Nazwa firmy jest wymagana."
  printf 'Imię i nazwisko kuratora wiedzy: '; read -r KURATOR
  [ -n "$KURATOR" ] || stop "Kurator jest wymagany."
  # Nazwa katalogu = to, co Obsidian pokazuje w tytule okna. Stąd polskie
  # znaki i myślnik, a nie „vault" czy „Drugi-Mozg".
  CEL="${KONIK_VAULT_DIR:-$HOME/Drugi Mózg — $FIRMA}"
  echo "  vault: $CEL"
  echo "  (instalator zapyta jeszcze o ID konta i token z panelu KONIK — Enter = uzupełnisz później)"
  echo
  bash "$WZORZEC_DIR/instalator/instaluj.sh" "$FIRMA" "$CEL" "$KURATOR" || rc=$?
  [ "$rc" -eq 0 ] || [ "$rc" -eq 3 ] || stop "Instalator zakończył się kodem $rc."

  # ─── 6. Obsidian ────────────────────────────────────────────────────────────
  krok "[6/6] Otwieram vault w Obsidianie"
  if [ -d /Applications/Obsidian.app ]; then
    open -a Obsidian; sleep 2
    open "obsidian://open?path=$(node -e 'console.log(encodeURIComponent(process.argv[1]))' "$CEL")"
    echo "  Vault powinien być w kolorach KONIK-a. Jeśli akcent jest fioletowy — zamknij i otwórz vault ponownie."
  else
    uwaga "Obsidiana nie ma — otwórz vault ręcznie: Open folder as vault → $CEL"
  fi

  echo
  printf '\033[1mZostaje człowiekowi:\033[0m\n'
  echo "  1. Claude Desktop → zaloguj klienta na JEGO konto, potem Cmd+Q i uruchom ponownie (serwery MCP czytane przy starcie)"
  echo "  2. Konto AI klienta → limit wydatków i alert, PRZED pierwszym użyciem"
  [ "$rc" -eq 3 ] && echo "  3. Uzupełnij ID konta i token w konfiguracji Claude Desktop (instalator wypisał gdzie)"
  echo "  •  Panel KONIK → Drugi Mózg → uruchom wdrożenie (LOCAL); wersje do wpisania: Obsidian $(wersja_app Obsidian), Claude $(wersja_app Claude)"
  exit "$rc"
}

main "$@"
