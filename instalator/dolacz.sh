#!/usr/bin/env bash
# ============================================
# KONIK Cortex · dołączenie do WSPÓLNEGO vaulta (macOS / Linux)
#
# Dla drugiej i każdej kolejnej osoby w firmie. Kurator założył vault przez
# instaluj.sh i wypchnął go do wspólnego repo (KONIK_REMOTE); ten skrypt
# klonuje to repo na maszynę kolejnej osoby i dokłada wszystko, czego clone
# NIE przenosi: hook lint-RODO (git nie wersjonuje .git/hooks), tożsamość
# tej osoby w commitach, serwer MCP i wpis w Claude Desktop.
#
# Użycie: ./dolacz.sh <adres-repo> "/sciezka/do/vaulta" "Imię Osoby" [client-id]
#
# Zmienne opcjonalne — te same co w instaluj.sh:
#   KONIK_API_URL, KONIK_CLAUDE_CONFIG, KONIK_MCP_DIR, KONIK_SKIP_MCP=1
#
# Zasada: trzy maszyny jednej firmy = trzy klony JEDNEGO repo. Nie kopiujemy
# wzorca po raz drugi — wtedy powstałyby trzy osobne vaulty o tej samej nazwie.
# ============================================
set -euo pipefail

REMOTE="${1:?Podaj adres wspólnego repo}"
CEL="${2:?Podaj katalog docelowy}"
OSOBA="${3:?Podaj imię osoby}"
CLIENT_ID="${4:-}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

API_URL="${KONIK_API_URL:-https://dev.koniksystems.com}"
MCP_DIR="${KONIK_MCP_DIR:-$HOME/.konik/konik-mcp}"

if [ -n "${KONIK_CLAUDE_CONFIG:-}" ]; then
  CLAUDE_CONFIG="$KONIK_CLAUDE_CONFIG"
elif [ "$(uname -s)" = "Darwin" ]; then
  CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
else
  CLAUDE_CONFIG="$HOME/.config/Claude/claude_desktop_config.json"
fi

[ -e "$CEL" ] && { echo "Katalog już istnieje: $CEL — nie nadpisuję."; exit 1; }
command -v node >/dev/null || { echo "Brak node — uruchom najpierw przygotuj-maszyne.sh."; exit 1; }
command -v git >/dev/null || { echo "Brak git — uruchom najpierw przygotuj-maszyne.sh."; exit 1; }

echo "[1/5] Klonuję wspólne repo -> $CEL"
# Gałąź jawnie: vault z instaluj.sh zawsze żyje na `main`, a HEAD pustego repo
# na hostingu bywa ustawiony na `master` — wtedy clone bez -b kończy się pustym
# katalogiem z ostrzeżeniem, które łatwo przeoczyć.
git clone -q -b main "$REMOTE" "$CEL"
# Sklonowane repo musi być vaultem z naszego wzorca: bez 00-START to nie jest
# Drugi Mózg, a bez .narzedzia/lint-rodo.js hook poniżej wywalałby każdy commit.
# Nieudany klon sprzątamy — to katalog, który sami przed chwilą utworzyliśmy,
# a zostawiony blokowałby ponowne uruchomienie komunikatem „katalog istnieje".
odrzuc() { echo "$1"; rm -rf "$CEL"; exit 1; }
[ -d "$CEL/00-START" ] || odrzuc "To repo nie wygląda na vault KONIK (brak 00-START). Sprawdź adres."
[ -f "$CEL/.narzedzia/lint-rodo.js" ] || odrzuc "W repo brakuje .narzedzia/lint-rodo.js — kurator instalował starszym wzorcem. Zgłoś do KONIK."

echo "[2/5] Tożsamość tej osoby w commitach"
# Slug bez spacji i polskich znaków do adresu — pełne imię zostaje w user.name.
SLUG="$(printf '%s' "$OSOBA" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '.' | sed 's/^\.//; s/\.$//')"
[ -n "$SLUG" ] || SLUG="osoba"
git -C "$CEL" config user.name "$OSOBA"
git -C "$CEL" config user.email "$SLUG@vault.local"

echo "[3/5] Hook pre-commit (lint-RODO) — clone go nie przenosi"
printf '#!/bin/sh\nnode .narzedzia/lint-rodo.js . || { echo "Commit zablokowany: dane osobowe w vaulcie."; exit 1; }\n' > "$CEL/.git/hooks/pre-commit"
chmod +x "$CEL/.git/hooks/pre-commit"
# Stan repo sprawdzamy od razu: dane osobowe wpuszczone z maszyny bez hooka
# mają wyjść TERAZ, a nie przy pierwszym commicie tej osoby.
node "$CEL/.narzedzia/lint-rodo.js" "$CEL"

if [ "${KONIK_SKIP_MCP:-}" = "1" ]; then
  echo "[4/5] Pomijam serwer MCP (KONIK_SKIP_MCP=1)"
  echo "[5/5] Pomijam wpięcie do Claude Desktop"
  echo
  echo "Vault: $CEL — bez połączenia z portalem KONIK."
  exit 0
fi

echo "[4/5] Serwer MCP -> $MCP_DIR"
mkdir -p "$MCP_DIR"
cp "$REPO/konik-mcp/index.js" "$REPO/konik-mcp/package.json" "$MCP_DIR/"
[ -f "$REPO/konik-mcp/package-lock.json" ] && cp "$REPO/konik-mcp/package-lock.json" "$MCP_DIR/"
if ! (cd "$MCP_DIR" && npm install --omit=dev --no-audit --no-fund); then
  echo
  echo "!! npm install w $MCP_DIR NIE POWIÓDŁ SIĘ (sieć? proxy?)."
  echo "   Vault jest gotowy, ale połączenia z portalem NIE MA."
  echo "   Dokończ: cd \"$MCP_DIR\" && npm install --omit=dev, potem uruchom skrypt ponownie."
  exit 1
fi

echo "[5/5] Wpinam serwer do Claude Desktop"
if [ -z "$CLIENT_ID" ] && [ -t 0 ]; then
  printf 'ID konta klienta (to samo co u kuratora, Enter = uzupełnię później): '
  read -r CLIENT_ID
fi
TOKEN=""
if [ -t 0 ]; then
  printf 'Token konik_agt_ (ten sam co u kuratora, Enter = uzupełnię później): '
  read -rs TOKEN
  printf '\n'
fi
REJ_RC=0
node "$REPO/narzedzia/rejestruj-mcp.js" \
  "$CLAUDE_CONFIG" "$MCP_DIR/index.js" "$API_URL" "${CLIENT_ID:-}" "$TOKEN" || REJ_RC=$?
if [ "$REJ_RC" -ne 0 ] && [ "$REJ_RC" -ne 3 ]; then
  echo "!! Nie udało się zapisać konfiguracji Claude Desktop (kod $REJ_RC)."
  exit "$REJ_RC"
fi

echo
if [ "$REJ_RC" -eq 3 ]; then
  echo "Vault gotowy. Połączenie z portalem CZEKA na uzupełnienie danych powyżej."
else
  echo "Gotowe."
fi
echo "Vault: $CEL (klon: $REMOTE)"
echo "MCP:   $MCP_DIR/index.js"
echo
echo "Następne kroki (człowiek):"
echo "  1. Obsidian -> Open folder as vault -> wskaż $CEL"
echo "  2. Obsidian -> Ustawienia -> Templates -> folder: 08-SZABLONY"
echo "  3. Zrestartuj Claude Desktop"
echo "  4. Rytm pracy: git pull rano, commit + push po sesji — konflikt rozstrzyga kurator"
exit "$REJ_RC"
