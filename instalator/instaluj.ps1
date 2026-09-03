# ============================================
# KONIK Cortex - instalator vaulta (Windows)
#
# Pusta maszyna -> dzialajacy vault w minuty (bramka produktu: < 15 min
# lacznie z instalacja Obsidiana i Claude Desktop, ktore robi czlowiek).
#
# Uzycie:
#   .\instaluj.ps1 -Firma "Cemet" -Cel "C:\Vaulty\Cemet" -Kurator "Anna Nowak"
#
# Co robi: kopiuje wzorzec, podstawia {{FIRMA}}/{{KURATOR}}/{{data}},
# zaklada git z hookiem lint-rodo (dane osobowe nie przejda commitu),
# robi commit startowy, stawia serwer MCP i wpina go do Claude Desktop.
# Odpowiednik instaluj.sh - oba maja robic to samo, w tej samej kolejnosci.
#
# Poza pobraniem zaleznosci npm NICZEGO nie wysyla poza maszyne.
# ============================================
param(
  [Parameter(Mandatory = $true)][string]$Firma,
  [Parameter(Mandatory = $true)][string]$Cel,
  [Parameter(Mandatory = $true)][string]$Kurator,
  [string]$ClientId = '',
  # Adres WSPOLNEGO repo (puste, prywatne): commit startowy idzie od razu tam,
  # a kolejne osoby dolaczaja przez dolacz.ps1.
  [string]$Remote = '',
  [string]$ApiUrl = 'https://dev.koniksystems.com',
  # Serwer MCP NIE mieszka w vaulcie: vault jest wersjonowany i skanowany pod
  # katem danych osobowych, a node_modules nie ma tam czego szukac.
  [string]$McpDir = (Join-Path $env:USERPROFILE '.konik\konik-mcp'),
  [string]$ClaudeConfig = (Join-Path $env:APPDATA 'Claude\claude_desktop_config.json'),
  [switch]$SkipMcp
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$wzorzec = Join-Path $repo 'wzorzec-vaulta'
if (-not (Test-Path $wzorzec)) { throw "Brak wzorca: $wzorzec" }
if (Test-Path (Join-Path $Cel '00-START')) { throw "Cel juz wyglada na vault: $Cel - nie nadpisuje." }

Write-Host "[1/6] Kopiuje wzorzec -> $Cel"
New-Item -ItemType Directory -Force $Cel | Out-Null
Copy-Item -Path (Join-Path $wzorzec '*') -Destination $Cel -Recurse -Force
# .gitkeep ZOSTAJE: git nie wersjonuje pustych folderow, wiec bez niego osoby
# dolaczajace przez dolacz.ps1 dostalyby vault bez 02-SPOTKANIA, 03-KONTA itd.
# Obsidian ukrywa pliki z kropka, klient ich nie widzi.

Write-Host "[2/6] Podstawiam nazwe firmy, kuratora i date"
$data = Get-Date -Format 'yyyy-MM-dd'
Get-ChildItem -Path $Cel -Recurse -Filter '*.md' | ForEach-Object {
  $t = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
  $t = $t.Replace('{{FIRMA}}', $Firma).Replace('{{KURATOR}}', $Kurator).Replace('{{data}}', $data)
  [System.IO.File]::WriteAllText($_.FullName, $t, (New-Object System.Text.UTF8Encoding $false))
}

Write-Host "[3/6] Kontrola danych osobowych (lint-rodo)"
New-Item -ItemType Directory -Force (Join-Path $Cel '.narzedzia') | Out-Null
Copy-Item (Join-Path $repo 'narzedzia\lint-rodo.js') (Join-Path $Cel '.narzedzia\lint-rodo.js') -Force
node (Join-Path $Cel '.narzedzia\lint-rodo.js') $Cel
if ($LASTEXITCODE -ne 0) { throw 'Wzorzec nie przeszedl lint-rodo - to blad wzorca, zglos do KONIK.' }

Write-Host "[4/6] Git + hook pre-commit"
Push-Location $Cel
git init -b main | Out-Null
# Tozsamosc LOKALNA repo vaulta - na maszynie klienta zwykle nie ma globalnej,
# a commit startowy nie moze od niej zalezec.
git config user.name $Kurator
git config user.email 'kurator@vault.local'
$hook = "#!/bin/sh`nnode .narzedzia/lint-rodo.js . || { echo 'Commit zablokowany: dane osobowe w vaulcie.'; exit 1; }`n"
[System.IO.File]::WriteAllText((Join-Path $Cel '.git\hooks\pre-commit'), $hook, (New-Object System.Text.UTF8Encoding $false))
git add -A | Out-Null
git commit -q -m "Start Drugiego Mozgu - $Firma ($data)"
if ($Remote) {
  # Push MUSI sie udac albo instalator staje - cichy brak remote'a dalby
  # trzy osobne vaulty zamiast jednego wspolnego.
  git remote add origin $Remote
  git push -q -u origin main
  if ($LASTEXITCODE -ne 0) { Pop-Location; throw "Push do $Remote nie powiodl sie - sprawdz dostep i uruchom: git -C `"$Cel`" push -u origin main" }
  Write-Host "      wypchnieto do wspolnego repo: $Remote"
}
Pop-Location

if ($SkipMcp) {
  Write-Host '[5/6] Pomijam serwer MCP (-SkipMcp)'
  Write-Host '[6/6] Pomijam wpiecie do Claude Desktop'
  Write-Host ''
  Write-Host "Vault: $Cel - bez polaczenia z portalem KONIK."
  exit 0
}

Write-Host "[5/6] Serwer MCP -> $McpDir"
New-Item -ItemType Directory -Force $McpDir | Out-Null
Copy-Item (Join-Path $repo 'konik-mcp\index.js') $McpDir -Force
Copy-Item (Join-Path $repo 'konik-mcp\package.json') $McpDir -Force
$lock = Join-Path $repo 'konik-mcp\package-lock.json'
if (Test-Path $lock) { Copy-Item $lock $McpDir -Force }
Push-Location $McpDir
# Zaleznosci sciagamy przy instalacji, a nie "kiedys": bez nich serwer wystartuje
# i od razu padnie, co u klienta wyglada jak awaria portalu, nie brak kroku.
# Bez --silent: przy zimnym cache npm potrafi mielic kilka minut, a cicha
# konsola wyglada jak zawieszony instalator.
npm install --omit=dev --no-audit --no-fund
$npmRc = $LASTEXITCODE
Pop-Location
if ($npmRc -ne 0) {
  Write-Host ''
  Write-Host "!! npm install w $McpDir NIE POWIODL SIE (siec? proxy?)."
  Write-Host '   Vault jest gotowy, ale polaczenia z portalem NIE MA.'
  Write-Host "   Dokoncz: cd `"$McpDir`"; npm install --omit=dev, potem uruchom instalator ponownie."
  exit 1
}

Write-Host '[6/6] Wpinam serwer do Claude Desktop'
# Read-Host czyta z konsoli, NIE ze standardowego wejscia - przy przekierowanym
# stdin (skrypt owijajacy, CI) zawisl by w nieskonczonosc zamiast polecieć dalej.
# Odpowiednik `[ -t 0 ]` z instaluj.sh.
$canPrompt = -not [Console]::IsInputRedirected
$token = ''
if ($canPrompt) {
  if (-not $ClientId) {
    $ClientId = Read-Host 'ID konta klienta (x-client-id z panelu, Enter = uzupelnie pozniej)'
  }
  # Token czytamy po cichu i NIE bierzemy go z parametru - parametry laduja
  # w historii PowerShella, a to jest poswiadczenie dostepu do konta klienta.
  $sec = Read-Host 'Token z panelu klienta (Enter = uzupelnie pozniej)' -AsSecureString
  $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}

# Kod 3 = wpis powstal, ale brakuje w nim tokenu albo id konta. To NIE jest
# awaria (vault dziala, plik zapisany), wiec podsumowanie musi sie wyswietlic -
# ale "Gotowe" juz nie, bo polaczenia z portalem jeszcze nie ma.
node (Join-Path $repo 'narzedzia/rejestruj-mcp.js') $ClaudeConfig (Join-Path $McpDir 'index.js') $ApiUrl $ClientId $token
$rejRc = $LASTEXITCODE
if ($rejRc -ne 0 -and $rejRc -ne 3) {
  Write-Host "!! Nie udalo sie zapisac konfiguracji Claude Desktop (kod $rejRc)."
  exit $rejRc
}

Write-Host ''
if ($rejRc -eq 3) {
  Write-Host 'Vault gotowy. Polaczenie z portalem CZEKA na uzupelnienie danych powyzej.'
} else {
  Write-Host 'Gotowe.'
}
Write-Host "Vault: $Cel"
Write-Host "MCP:   $(Join-Path $McpDir 'index.js')"
Write-Host "Config Claude: $ClaudeConfig"
Write-Host ''
Write-Host 'Nastepne kroki (czlowiek):'
Write-Host "  1. Obsidian -> Open folder as vault -> wskaz $Cel"
Write-Host '  2. Obsidian -> Ustawienia -> Templates -> folder: 08-SZABLONY'
Write-Host '  3. Zrestartuj Claude Desktop (serwery MCP wczytuja sie przy starcie)'
Write-Host '  4. Sprawdz w Claude: "pokaz stan Drugiego Mozgu" -> narzedzie drugi_mozg'
Write-Host '  5. Konto AI klienta: limit wydatkow + alert PRZED pierwszym uzyciem'
exit $rejRc
