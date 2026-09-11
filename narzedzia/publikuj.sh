#!/usr/bin/env bash
# ============================================
# KONIK Cortex · publikuj — wzorzec + bootstrapy do KONIK CORE, pod
# https://dev.koniksystems.com/cortex/
#
# Repo wzorca jest prywatne, więc bootstrap nie może ciągnąć z GitHuba.
# Zamiast tego trzy pliki lądują w `dashboard/public/cortex/` w KONIK CORE
# i jadą na produkcję z normalnym deployem frontendu:
#
#   instaluj       ← instalator/bootstrap.sh   (mac:  bash -c "$(curl -fsSL …/instaluj)")
#   instaluj.ps1   ← instalator/bootstrap.ps1  (win:  irm …/instaluj.ps1 | iex)
#   wzorzec.zip    ← git archive HEAD           (to, co bootstrap rozpakowuje)
#
# `git archive` bierze WYŁĄCZNIE to, co zacommitowane. To celowe: klient
# dostaje wersję, którą da się odtworzyć z historii, a nie stan czyjegoś
# katalogu roboczego z niedokończoną zmianą.
#
# Po tym skrypcie zostaje ręczny commit w KONIK CORE — bo to tam decyduje
# się, co idzie na prod, i tam jest bramka CI.
#
# Użycie: ./narzedzia/publikuj.sh   (z katalogu repo wzorca)
#   KONIK_CORE_DIR — gdzie jest KONIK CORE (domyślnie ../KONIK CORE)
# ============================================
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CORE="${KONIK_CORE_DIR:-$REPO/../KONIK CORE}"
CEL="$CORE/dashboard/public/cortex"

[ -d "$CORE/dashboard/public" ] || { echo "Nie widzę KONIK CORE pod: $CORE (ustaw KONIK_CORE_DIR)"; exit 1; }
cd "$REPO"

if [ -n "$(git status --porcelain)" ]; then
  echo "!! Repo wzorca ma niezacommitowane zmiany — git archive ich NIE weźmie."
  echo "   Zacommituj albo świadomie publikuj poprzedni stan. Przerywam."
  exit 1
fi

mkdir -p "$CEL"
git archive --format=zip -o "$CEL/wzorzec.zip" HEAD
cp instalator/bootstrap.sh  "$CEL/instaluj"
cp instalator/bootstrap.ps1 "$CEL/instaluj.ps1"

# Znacznik wersji: sam hash wystarczy, żeby przy zgłoszeniu od klienta
# wiedzieć, KTÓRY wzorzec dostał.
git rev-parse --short HEAD > "$CEL/WERSJA"

echo "Opublikowano do $CEL:"
ls -la "$CEL" | tail -n +2 | awk '{print "  " $5 "\t" $9}'
echo
echo "Teraz w KONIK CORE: git add dashboard/public/cortex && commit → PR → deploy."
