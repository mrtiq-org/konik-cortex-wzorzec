# ============================================
# KONIK Cortex - dolaczenie do WSPOLNEGO vaulta (Windows)
#
# Dla drugiej i kazdej kolejnej osoby w firmie. Kurator zalozyl vault przez
# instaluj.ps1 i wypchnal go do wspolnego repo (-Remote); ten skrypt klonuje
# to repo na maszyne kolejnej osoby i doklada to, czego clone NIE przenosi:
# hook lint-RODO (git nie wersjonuje .git\hooks), tozsamosc tej osoby
# w commitach, serwer MCP i wpis w Claude Desktop.
#
# Uzycie:
#   .\dolacz.ps1 -Remote "https://github.com/firma/vault.git" -Cel "C:\Vaulty\Cemet" -Osoba "Jan Kowalski"
#
# Odpowiednik dolacz.sh - oba maja robic to samo, w tej samej kolejnosci.
# ============================================
param(
  [Parameter(Mandatory = $true)][string]$Remote,
  [Parameter(Mandatory = $true)][string]$Cel,
  [Parameter(Mandatory = $true)][string]$Osoba,
  [string]$ClientId = '',
  [string]$ApiUrl = 'https://dev.koniksystems.com',
  [string]$McpDir = (Join-Path $env:USERPROFILE '.konik\konik-mcp'),
  [string]$ClaudeConfig = (Join-Path $env:APPDATA 'Claude\claude_desktop_config.json'),
  [switch]$SkipMcp
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
if (Test-Path $Cel) { throw "Katalog juz istnieje: $Cel - nie nadpisuje." }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Brak node - uruchom najpierw przygotuj-maszyne.ps1.' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Brak git - uruchom najpierw przygotuj-maszyne.ps1.' }

Write-Host "[1/5] Klonuje wspolne repo -> $Cel"
# Galaz jawnie: vault z instaluj.ps1 zawsze zyje na `main`, a HEAD pustego repo
# na hostingu bywa ustawiony na `master` - wtedy clone bez -b konczy sie pustym
# katalogiem z ostrzezeniem, ktore latwo przeoczyc.
git clone -q -b main $Remote $Cel
if ($LASTEXITCODE -ne 0) { throw "git clone nie powiodl sie (kod $LASTEXITCODE)." }
# Nieudany klon sprzatamy - to katalog, ktory sami przed chwila utworzylismy,
# a zostawiony blokowalby ponowne uruchomienie komunikatem "katalog istnieje".
function Odrzuc([string]$powod) { Remove-Item -Recurse -Force $Cel -ErrorAction SilentlyContinue; throw $powod }
if (-not (Test-Path (Join-Path $Cel '00-START'))) { Odrzuc 'To repo nie wyglada na vault KONIK (brak 00-START). Sprawdz adres.' }
if (-not (Test-Path (Join-Path $Cel '.narzedzia\lint-rodo.js'))) { Odrzuc 'W repo brakuje .narzedzia\lint-rodo.js - kurator instalowal starszym wzorcem. Zglos do KONIK.' }

Write-Host '[2/5] Tozsamosc tej osoby w commitach'
$slug = ($Osoba.ToLowerInvariant() -replace '[^a-z0-9]+', '.').Trim('.')
if (-not $slug) { $slug = 'osoba' }
Push-Location $Cel
git config user.name $Osoba
git config user.email "$slug@vault.local"

Write-Host '[3/5] Hook pre-commit (lint-RODO) - clone go nie przenosi'
$hook = "#!/bin/sh`nnode .narzedzia/lint-rodo.js . || { echo 'Commit zablokowany: dane osobowe w vaulcie.'; exit 1; }`n"
[System.IO.File]::WriteAllText((Join-Path $Cel '.git\hooks\pre-commit'), $hook, (New-Object System.Text.UTF8Encoding $false))
Pop-Location
# Stan repo sprawdzamy od razu: dane osobowe wpuszczone z maszyny bez hooka
# maja wyjsc TERAZ, nie przy pierwszym commicie tej osoby.
node (Join-Path $Cel '.narzedzia\lint-rodo.js') $Cel
if ($LASTEXITCODE -ne 0) { throw 'Wspolne repo zawiera dane osobowe - wyczysc je u kuratora, zanim dolaczysz kolejna osobe.' }

if ($SkipMcp) {
  Write-Host '[4/5] Pomijam serwer MCP (-SkipMcp)'
  Write-Host '[5/5] Pomijam wpiecie do Claude Desktop'
  Write-Host ''
  Write-Host "Vault: $Cel - bez polaczenia z portalem KONIK."
  exit 0
}

Write-Host "[4/5] Serwer MCP -> $McpDir"
New-Item -ItemType Directory -Force $McpDir | Out-Null
Copy-Item (Join-Path $repo 'konik-mcp\index.js') $McpDir -Force
Copy-Item (Join-Path $repo 'konik-mcp\package.json') $McpDir -Force
$lock = Join-Path $repo 'konik-mcp\package-lock.json'
if (Test-Path $lock) { Copy-Item $lock $McpDir -Force }
Push-Location $McpDir
npm install --omit=dev --no-audit --no-fund
$npmRc = $LASTEXITCODE
Pop-Location
if ($npmRc -ne 0) {
  Write-Host ''
  Write-Host "!! npm install w $McpDir NIE POWIODL SIE (siec? proxy?)."
  Write-Host '   Vault jest gotowy, ale polaczenia z portalem NIE MA.'
  Write-Host "   Dokoncz: cd `"$McpDir`"; npm install --omit=dev, potem uruchom skrypt ponownie."
  exit 1
}

Write-Host '[5/5] Wpinam serwer do Claude Desktop'
$canPrompt = -not [Console]::IsInputRedirected
$token = ''
if ($canPrompt) {
  if (-not $ClientId) {
    $ClientId = Read-Host 'ID konta klienta (to samo co u kuratora, Enter = uzupelnie pozniej)'
  }
  $sec = Read-Host 'Token konik_agt_ (ten sam co u kuratora, Enter = uzupelnie pozniej)' -AsSecureString
  $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}
node (Join-Path $repo 'narzedzia/rejestruj-mcp.js') $ClaudeConfig (Join-Path $McpDir 'index.js') $ApiUrl $ClientId $token
$rejRc = $LASTEXITCODE
if ($rejRc -ne 0 -and $rejRc -ne 3) {
  Write-Host "!! Nie udalo sie zapisac konfiguracji Claude Desktop (kod $rejRc)."
  exit $rejRc
}

Write-Host ''
if ($rejRc -eq 3) { Write-Host 'Vault gotowy. Polaczenie z portalem CZEKA na uzupelnienie danych powyzej.' }
else { Write-Host 'Gotowe.' }
Write-Host "Vault: $Cel (klon: $Remote)"
Write-Host "MCP:   $(Join-Path $McpDir 'index.js')"
Write-Host ''
Write-Host 'Nastepne kroki (czlowiek):'
Write-Host "  1. Obsidian -> Open folder as vault -> wskaz $Cel"
Write-Host '  2. Obsidian -> Ustawienia -> Templates -> folder: 08-SZABLONY'
Write-Host '  3. Zrestartuj Claude Desktop'
Write-Host '  4. Rytm pracy: git pull rano, commit + push po sesji - konflikt rozstrzyga kurator'
exit $rejRc
