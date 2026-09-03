# ============================================
# KONIK Cortex - przygotowanie maszyny (Windows)
#
# Krok ZERO przed instaluj.ps1: stawia to, czego instalator vaulta wymaga,
# a czego sam nie instaluje - Node.js LTS, git, Obsidian, Claude Desktop.
# Zrodlo: winget (wbudowany w Windows 10/11 jako "App Installer").
#
# Uzycie (PowerShell jako zwykly uzytkownik; winget sam poprosi o UAC):
#   .\przygotuj-maszyne.ps1
#   .\przygotuj-maszyne.ps1 -ObsidianWersja 1.13.7 -ClaudeWersja 1.44121.2
#
# Wersje: bez parametrow winget bierze NAJNOWSZE. Kontrakt Danych par. 10 mowi
# "wersje zamrozone" - jesli WERSJE.md ma juz wpis, podaj go parametrem,
# zeby trzy maszyny jednego klienta dostaly identyczny zestaw.
#
# Czego skrypt NIE robi, bo nie moze: nie loguje Claude Desktop na konto
# osoby, nie ustawia limitu wydatkow, nie otwiera vaulta w Obsidianie.
# Te trzy rzeczy robi czlowiek i skrypt wypisuje je na koncu.
#
# Idempotentny: zainstalowany pakiet pomija, nie reinstaluje.
# ============================================
param(
  [string]$ObsidianWersja = '',
  [string]$ClaudeWersja = '',
  [string]$NodeWersja = '',
  [string]$GitWersja = ''
)
$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host '!! Brak winget. Zainstaluj "App Installer" z Microsoft Store (albo zaktualizuj Windows) i uruchom ponownie.'
  exit 1
}

# Kolejnosc ma znaczenie tylko dla czytelnosci logu - pakiety sa niezalezne.
$pakiety = @(
  @{ Id = 'OpenJS.NodeJS.LTS'; Nazwa = 'Node.js LTS';    Wersja = $NodeWersja },
  @{ Id = 'Git.Git';           Nazwa = 'git';            Wersja = $GitWersja },
  @{ Id = 'Obsidian.Obsidian'; Nazwa = 'Obsidian';       Wersja = $ObsidianWersja },
  @{ Id = 'Anthropic.Claude';  Nazwa = 'Claude Desktop'; Wersja = $ClaudeWersja }
)

function Zainstalowana([string]$id) {
  # winget list zwraca 0 gdy znalazl pakiet; tekst jest zlokalizowany, kod nie.
  $null = winget list --id $id --exact --accept-source-agreements 2>$null
  return ($LASTEXITCODE -eq 0)
}

$bledy = @()
$i = 0
foreach ($p in $pakiety) {
  $i++
  $etykieta = "[$i/$($pakiety.Count)] $($p.Nazwa)"
  if (Zainstalowana $p.Id) {
    Write-Host "$etykieta - juz jest, pomijam"
    continue
  }
  Write-Host "$etykieta - instaluje ($($p.Id))"
  $args = @('install', '--id', $p.Id, '--exact', '--silent',
            '--accept-package-agreements', '--accept-source-agreements')
  if ($p.Wersja -ne '') { $args += @('--version', $p.Wersja) }
  & winget @args
  if ($LASTEXITCODE -ne 0) {
    $bledy += "$($p.Nazwa) (kod $LASTEXITCODE)"
    Write-Host "!! $($p.Nazwa): winget zakonczyl sie kodem $LASTEXITCODE"
  }
}

# Swiezo zainstalowany node/git NIE jest w PATH biezacej sesji - odswiezamy
# z rejestru, zeby weryfikacja ponizej nie klamala "brak node" tuz po instalacji.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')

Write-Host ''
Write-Host 'Weryfikacja:'
$nodeOk = $false
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
  $v = (& node -v).TrimStart('v')
  $major = [int]($v.Split('.')[0])
  if ($major -ge 18) { $nodeOk = $true; Write-Host "  node    $v" }
  else { Write-Host "  node    $v - ZA STARY, instalator wymaga 18+"; $bledy += 'node < 18' }
} else {
  Write-Host '  node    BRAK w PATH'; $bledy += 'node nie widoczny'
}
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) { Write-Host "  git     $((& git --version) -replace 'git version ','')" }
else { Write-Host '  git     BRAK w PATH'; $bledy += 'git nie widoczny' }

# Wersje aplikacji - operator wpisuje je w portalu (Drugi Mozg -> wersje
# komponentow) i, przy pierwszym kliencie, do WERSJE.md po regresji.
foreach ($id in 'Obsidian.Obsidian', 'Anthropic.Claude') {
  $linia = (winget list --id $id --exact --accept-source-agreements 2>$null | Select-Object -Last 1)
  if ($linia) { Write-Host "  $id  ->  $($linia.Trim())" }
}

Write-Host ''
if ($bledy.Count -gt 0) {
  Write-Host "Nie wszystko sie udalo: $($bledy -join ', ')."
  Write-Host 'Popraw powyzsze i uruchom skrypt ponownie - zainstalowane pakiety pominie.'
  exit 1
}

Write-Host 'Maszyna gotowa pod instaluj.ps1.'
Write-Host ''
Write-Host 'Zostaje czlowiekowi (skrypt tego nie zrobi):'
Write-Host '  1. Uruchom Claude Desktop i zaloguj te osobe na JEJ konto'
Write-Host '  2. Konto AI: limit wydatkow + alert - PRZED pierwszym uzyciem'
Write-Host '  3. Uruchom Obsidian raz (pierwsze uruchomienie tworzy konfiguracje)'
Write-Host '  4. Otworz NOWE okno PowerShell (swiezy PATH) i odpal instaluj.ps1'
