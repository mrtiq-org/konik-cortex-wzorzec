# ============================================
# KONIK Cortex - bootstrap (Windows) - jedna linia zamiast osmiu krokow.
#
#   irm https://dev.koniksystems.com/cortex/instaluj.ps1 | iex
#
# Odpowiednik bootstrap.sh dla macOS. Co robi:
#   1. Node LTS, Obsidian, Claude Desktop - przez winget (wbudowany w Win 10/11)
#   2. wzorzec.zip z naszej domeny -> %USERPROFILE%\.konik\wzorzec
#   3. instaluj.ps1 z tego wzorca (vault, RODO, git, MCP, Claude Desktop)
#   4. otwiera vault w Obsidianie (obsidian://)
#
# `iex` wykonuje skrypt jako tekst, wiec nie ma tu bloku param() - ustawienia
# ida przez zmienne srodowiskowe (KONIK_CORTEX_BASE, KONIK_VAULT_DIR).
# Read-Host czyta z konsoli, nie ze stdin, wiec pytania dzialaja przy `| iex`.
#
# Plik jest czystym ASCII: PowerShell 5.1 czyta skrypt bez BOM jako ANSI
# i polskie znaki w komentarzach potrafia wywrocic parser.
# ============================================
$ErrorActionPreference = 'Stop'

$Base = if ($env:KONIK_CORTEX_BASE) { $env:KONIK_CORTEX_BASE } else { 'https://dev.koniksystems.com/cortex' }
$KonikHome = Join-Path $env:USERPROFILE '.konik'
$WzorzecDir = Join-Path $KonikHome 'wzorzec'
$Tmp = Join-Path $env:TEMP ("konik-cortex-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force $Tmp | Out-Null

function Krok([string]$t) { Write-Host ''; Write-Host $t -ForegroundColor White }
function Uwaga([string]$t) { Write-Host "!! $t" -ForegroundColor Yellow }
function Stop-Bootstrap([string]$t) { Write-Host "STOP: $t" -ForegroundColor Red; exit 1 }

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Stop-Bootstrap 'Brak winget. Zainstaluj "App Installer" ze sklepu Microsoft Store i uruchom ponownie.'
}

$bledy = @()

# winget instaluje po ID; zainstalowane pomija po TYM, CZY RZECZ DZIALA
# (polecenie w PATH albo katalog aplikacji), nie po tym, czy winget ja zna -
# Node z instalatora .msi ze strony producenta tez ma zostac rozpoznany.
function Zainstaluj([string]$etykieta, [string]$id, [scriptblock]$jest) {
  Krok $etykieta
  if (& $jest) { Write-Host '  jest, pomijam'; return }
  Write-Host "  instaluje ($id)"
  winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) { $script:bledy += $etykieta }
}

Zainstaluj '[1/6] Node.js' 'OpenJS.NodeJS.LTS' { [bool](Get-Command node -ErrorAction SilentlyContinue) }
Zainstaluj '[2/6] Obsidian' 'Obsidian.Obsidian' { Test-Path (Join-Path $env:LOCALAPPDATA 'Obsidian\Obsidian.exe') }
Zainstaluj '[3/6] Claude Desktop' 'Anthropic.Claude' { Test-Path (Join-Path $env:LOCALAPPDATA 'AnthropicClaude\claude.exe') }

# Swiezy node z winget nie jest w PATH biezacej sesji - dolaczamy typowe
# lokalizacje, zeby instalator vaulta go zobaczyl bez otwierania nowego okna.
$env:Path = "$env:ProgramFiles\nodejs;$env:LOCALAPPDATA\Programs\nodejs;" + $env:Path
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Stop-Bootstrap 'Node zainstalowany, ale nie ma go w PATH. Otworz NOWE okno PowerShell i uruchom bootstrap ponownie.'
}

Krok '[4/6] Wzorzec vaulta'
$zip = Join-Path $Tmp 'wzorzec.zip'
Invoke-WebRequest -Uri "$Base/wzorzec.zip" -OutFile $zip -UseBasicParsing
if (Test-Path $WzorzecDir) { Remove-Item -Recurse -Force $WzorzecDir }
New-Item -ItemType Directory -Force $WzorzecDir | Out-Null
Expand-Archive -Path $zip -DestinationPath $WzorzecDir -Force
# ZIP moze miec jeden katalog nadrzedny - splaszczamy.
if (-not (Test-Path (Join-Path $WzorzecDir 'instalator\instaluj.ps1'))) {
  $inner = Get-ChildItem $WzorzecDir -Recurse -Filter 'instaluj.ps1' -Depth 3 | Select-Object -First 1
  if (-not $inner) { Stop-Bootstrap 'W wzorzec.zip nie ma instalator\instaluj.ps1' }
  $root = Split-Path (Split-Path $inner.FullName -Parent) -Parent
  $flat = Join-Path $Tmp 'flat'
  Move-Item $root $flat
  Remove-Item -Recurse -Force $WzorzecDir
  Move-Item $flat $WzorzecDir
}
Write-Host "  $WzorzecDir"

if ($bledy.Count -gt 0) {
  Uwaga "Nie zainstalowano: $($bledy -join ', '). Vault i tak powstanie - dokoncz to recznie przed oddaniem klientowi."
}

Krok '[5/6] Vault + serwer MCP'
$Firma = Read-Host 'Nazwa firmy klienta'
if (-not $Firma) { Stop-Bootstrap 'Nazwa firmy jest wymagana.' }
$Kurator = Read-Host 'Imie i nazwisko kuratora wiedzy'
if (-not $Kurator) { Stop-Bootstrap 'Kurator jest wymagany.' }
# Nazwa katalogu = to, co Obsidian pokazuje w tytule okna.
$Cel = if ($env:KONIK_VAULT_DIR) { $env:KONIK_VAULT_DIR } else { Join-Path $env:USERPROFILE ("Drugi Mozg - " + $Firma) }
Write-Host "  vault: $Cel"
Write-Host '  (instalator zapyta jeszcze o ID konta i token z panelu KONIK - Enter = uzupelnisz pozniej)'
Write-Host ''
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $WzorzecDir 'instalator\instaluj.ps1') -Firma $Firma -Cel $Cel -Kurator $Kurator
$rc = $LASTEXITCODE
if ($rc -ne 0 -and $rc -ne 3) { Stop-Bootstrap "Instalator zakonczyl sie kodem $rc." }

Krok '[6/6] Otwieram vault w Obsidianie'
$obs = Join-Path $env:LOCALAPPDATA 'Obsidian\Obsidian.exe'
if (Test-Path $obs) {
  Start-Process $obs; Start-Sleep -Seconds 2
  Start-Process ("obsidian://open?path=" + [uri]::EscapeDataString($Cel))
  Write-Host '  Vault powinien byc w kolorach KONIK-a. Jesli akcent jest fioletowy - zamknij i otworz vault ponownie.'
} else {
  Uwaga "Obsidiana nie ma - otworz vault recznie: Open folder as vault -> $Cel"
}

Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue

Write-Host ''
Write-Host 'Zostaje czlowiekowi:' -ForegroundColor White
Write-Host '  1. Claude Desktop -> zaloguj klienta na JEGO konto, potem zamknij calkowicie i uruchom ponownie'
Write-Host '  2. Konto AI klienta -> limit wydatkow i alert, PRZED pierwszym uzyciem'
if ($rc -eq 3) { Write-Host '  3. Uzupelnij ID konta i token w konfiguracji Claude Desktop (instalator wypisal gdzie)' }
Write-Host '  -  Panel KONIK -> Drugi Mozg -> uruchom wdrozenie (LOCAL), wpisz kuratora i wersje komponentow'
exit $rc
