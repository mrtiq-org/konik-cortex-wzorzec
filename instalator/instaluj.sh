#!/usr/bin/env bash
# ============================================
# KONIK Cortex · instalator vaulta (macOS / Linux)
#
# Uzycie: ./instaluj.sh "Nazwa Firmy" "/sciezka/do/vaulta" "Imie Kuratora" [client-id]
#
# Robi cala mechanike wdrozenia: vault z wzorca, kontrola RODO, git z hookiem,
# serwer MCP i wpiecie go do Claude Desktop. Czlowiekowi zostaje Obsidian
# i limit wydatkow na koncie AI.
#
# Zmienne opcjonalne:
#   KONIK_API_URL       — domyslnie https://dev.koniksystems.com
#   KONIK_CLAUDE_CONFIG — plik konfiguracyjny Claude Desktop (gdy nietypowy)
#   KONIK_MCP_DIR       — gdzie wyladuje serwer MCP (domyslnie ~/.konik/konik-mcp)
#   KONIK_SKIP_MCP=1    — pomin kroki 5-6 (sam vault, bez polaczenia z KONIKIEM)
#
# Serwer MCP NIE mieszka w vaulcie: vault jest wersjonowany i skanowany pod
# katem danych osobowych, a node_modules nie ma tam czego szukac. Stad ~/.konik.
# ============================================
set -euo pipefail

FIRMA="${1:?Podaj nazwę firmy}"
CEL="${2:?Podaj katalog docelowy}"
KURATOR="${3:?Podaj imię kuratora}"
CLIENT_ID="${4:-}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
WZORZEC="$REPO/wzorzec-vaulta"
DATA="$(date +%Y-%m-%d)"

API_URL="${KONIK_API_URL:-https://dev.koniksystems.com}"
MCP_DIR="${KONIK_MCP_DIR:-$HOME/.konik/konik-mcp}"

if [ -n "${KONIK_CLAUDE_CONFIG:-}" ]; then
  CLAUDE_CONFIG="$KONIK_CLAUDE_CONFIG"
elif [ "$(uname -s)" = "Darwin" ]; then
  CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
else
  CLAUDE_CONFIG="$HOME/.config/Claude/claude_desktop_config.json"
fi

[ -d "$WZORZEC" ] || { echo "Brak wzorca: $WZORZEC"; exit 1; }
[ -d "$CEL/00-START" ] && { echo "Cel już wygląda na vault: $CEL — nie nadpisuję."; exit 1; }
command -v node >/dev/null || { echo "Brak node — zainstaluj Node.js i uruchom ponownie."; exit 1; }

echo "[1/6] Kopiuję wzorzec -> $CEL"
mkdir -p "$CEL"
cp -R "$WZORZEC/." "$CEL/"
find "$CEL" -name '.gitkeep' -delete

echo "[2/6] Podstawiam nazwę firmy, kuratora i datę"
find "$CEL" -name '*.md' -print0 | while IFS= read -r -d '' f; do
  sed -i.bak -e "s/{{FIRMA}}/$FIRMA/g" -e "s/{{KURATOR}}/$KURATOR/g" -e "s/{{data}}/$DATA/g" "$f" && rm -f "$f.bak"
done

echo "[3/6] Kontrola danych osobowych (lint-rodo)"
mkdir -p "$CEL/.narzedzia"
cp "$REPO/narzedzia/lint-rodo.js" "$CEL/.narzedzia/"
node "$CEL/.narzedzia/lint-rodo.js" "$CEL"

echo "[4/6] Git + hook pre-commit"
(
  cd "$CEL"
  git init -b main >/dev/null
  # Tożsamość LOKALNA repo vaulta — na maszynie klienta zwykle nie ma globalnej,
  # a commit startowy nie może od niej zależeć.
  git config user.name "$KURATOR"
  git config user.email "kurator@vault.local"
  printf '#!/bin/sh\nnode .narzedzia/lint-rodo.js . || { echo "Commit zablokowany: dane osobowe w vaulcie."; exit 1; }\n' > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  git add -A >/dev/null
  git commit -q -m "Start Drugiego Mozgu — $FIRMA ($DATA)"
)

if [ "${KONIK_SKIP_MCP:-}" = "1" ]; then
  echo "[5/6] Pomijam serwer MCP (KONIK_SKIP_MCP=1)"
  echo "[6/6] Pomijam wpięcie do Claude Desktop"
  echo
  echo "Vault: $CEL — bez połączenia z portalem KONIK."
  exit 0
fi

echo "[5/6] Serwer MCP -> $MCP_DIR"
mkdir -p "$MCP_DIR"
cp "$REPO/konik-mcp/index.js" "$REPO/konik-mcp/package.json" "$MCP_DIR/"
[ -f "$REPO/konik-mcp/package-lock.json" ] && cp "$REPO/konik-mcp/package-lock.json" "$MCP_DIR/"
# Zależności ściągamy przy instalacji, a nie „kiedyś": bez nich serwer wystartuje
# i od razu padnie, co u klienta wygląda jak awaria portalu, nie brak kroku.
# Bez `--silent`: przy zimnym cache npm potrafi mielić kilka minut, a cicha
# konsola wygląda jak zawieszony instalator (zmierzone: 10 min na czysto,
# 9 s przy ciepłym cache). Operator ma widzieć, że coś się dzieje.
if ! (cd "$MCP_DIR" && npm install --omit=dev --no-audit --no-fund); then
  echo
  echo "!! npm install w $MCP_DIR NIE POWIÓDŁ SIĘ (sieć? proxy?)."
  echo "   Vault jest gotowy, ale połączenia z portalem NIE MA."
  echo "   Dokończ: cd \"$MCP_DIR\" && npm install --omit=dev, potem uruchom instalator ponownie."
  exit 1
fi

echo "[6/6] Wpinam serwer do Claude Desktop"
if [ -z "$CLIENT_ID" ] && [ -t 0 ]; then
  printf 'ID konta klienta (x-client-id z panelu, Enter = uzupełnię później): '
  read -r CLIENT_ID
fi
TOKEN=""
if [ -t 0 ]; then
  # Token czytamy po cichu i NIE bierzemy go z argumentu — argumenty lądują
  # w historii powłoki, a to jest poświadczenie dostępu do konta klienta.
  printf 'Token z panelu klienta (Enter = uzupełnię później): '
  read -rs TOKEN
  printf '\n'
fi

# Kod 3 = wpis powstal, ale brakuje w nim tokenu albo id konta. To NIE jest
# awaria (vault dziala, plik zapisany), wiec podsumowanie musi sie wyswietlic —
# ale „Gotowe" juz nie, bo polaczenia z portalem jeszcze nie ma.
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
echo "Vault: $CEL"
echo "MCP:   $MCP_DIR/index.js"
echo "Config Claude: $CLAUDE_CONFIG"
echo
echo "Następne kroki (człowiek):"
echo "  1. Obsidian -> Open folder as vault -> wskaż $CEL"
echo "  2. Obsidian -> Ustawienia -> Templates -> folder: 08-SZABLONY"
echo "  3. Zrestartuj Claude Desktop (serwery MCP wczytują się przy starcie)"
echo "  4. Sprawdź w Claude: „pokaż stan Drugiego Mózgu\" -> narzędzie drugi_mozg"
echo "  5. Konto AI klienta: limit wydatków + alert PRZED pierwszym użyciem"
exit "$REJ_RC"
