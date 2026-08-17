#!/usr/bin/env node
// ============================================
// KONIK Cortex · rejestruj-mcp — wpina serwer `konik-portal` do Claude Desktop.
//
// Klient ma w Claude Desktop jeden plik konfiguracyjny na WSZYSTKIE serwery
// MCP. Dopisanie do niego z palca to najczęstsze miejsce na pomyłkę podczas
// wdrożenia, a nadpisanie go w całości skasowałoby cudze serwery. Stąd ten
// skrypt zamiast instrukcji „wklej JSON".
//
// Trzy zasady, bo to plik, którego nie jesteśmy właścicielem:
//  1. NIE NADPISUJEMY cudzych wpisów — scalamy wyłącznie klucz `konik-portal`.
//  2. Plik nie do sparsowania = STOP z komunikatem. Uszkodzony JSON znaczy,
//     że ktoś go ręcznie edytuje albo Claude trzyma tam coś, czego nie znamy —
//     w obu wypadkach nadpisanie zabrałoby klientowi konfigurację.
//  3. Zawsze kopia zapasowa przed zapisem, z datą w nazwie.
//
// Token: gdy nie podano, a wpis już istnieje — ZOSTAJE stary. Gdy nie ma ani
// nowego, ani starego, wpisujemy pusty string i mówimy o tym głośno. Cichy
// pusty token dałby serwer, który wygląda na skonfigurowany i nie działa.
//
// Uruchomienie:
//   node rejestruj-mcp.js <plik-konfiguracji> <sciezka-do-index.js> <api-url> <client-id> [token]
// ============================================

const fs = require('fs');
const path = require('path');

const [configPath, serverEntry, apiUrl, clientIdArg, tokenArg] = process.argv.slice(2);

// `client-id` i `token` moga byc puste: operator uzupelnia je czasem dopiero po
// zalozeniu konta klienta w panelu. Braki NIE sa ciche — patrz koniec pliku.
if (!configPath || !serverEntry || !apiUrl) {
  console.error('Uzycie: node rejestruj-mcp.js <plik-konfiguracji> <index.js> <api-url> [client-id] [token]');
  process.exit(2);
}

const KLUCZ = 'konik-portal';
const absEntry = path.resolve(serverEntry);

if (!fs.existsSync(absEntry)) {
  console.error(`Nie ma pliku serwera MCP: ${absEntry}`);
  process.exit(1);
}

let config = {};
if (fs.existsSync(configPath)) {
  const raw = fs.readFileSync(configPath, 'utf8');
  if (raw.trim()) {
    try {
      config = JSON.parse(raw);
    } catch (err) {
      console.error(`STOP: ${configPath} nie jest poprawnym JSON-em (${err.message}).`);
      console.error('Nie nadpisuje pliku — popraw go recznie albo usun i uruchom ponownie.');
      process.exit(1);
    }
  }
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backup = `${configPath}.bak-${stamp}`;
  fs.copyFileSync(configPath, backup);
  console.log(`Kopia zapasowa: ${backup}`);
} else {
  fs.mkdirSync(path.dirname(configPath), { recursive: true });
}

if (typeof config !== 'object' || config === null || Array.isArray(config)) {
  console.error(`STOP: ${configPath} zawiera ${Array.isArray(config) ? 'tablice' : typeof config}, a nie obiekt konfiguracji.`);
  process.exit(1);
}

const servers = (config.mcpServers && typeof config.mcpServers === 'object' && !Array.isArray(config.mcpServers))
  ? config.mcpServers
  : {};
const poprzedni = servers[KLUCZ];
const token = tokenArg || poprzedni?.env?.KONIK_TOKEN || '';
const clientId = clientIdArg || poprzedni?.env?.KONIK_CLIENT_ID || '';

const inni = Object.keys(servers).filter((k) => k !== KLUCZ);

servers[KLUCZ] = {
  command: 'node',
  args: [absEntry],
  env: {
    KONIK_API_URL: apiUrl,
    KONIK_TOKEN: token,
    KONIK_CLIENT_ID: clientId,
  },
};

config.mcpServers = servers;
fs.writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`, 'utf8');

console.log(`${poprzedni ? 'Zaktualizowano' : 'Dodano'} serwer "${KLUCZ}" w ${configPath}`);
if (inni.length) console.log(`Nietkniete inne serwery MCP: ${inni.join(', ')}`);
const braki = [!clientId && 'KONIK_CLIENT_ID', !token && 'KONIK_TOKEN'].filter(Boolean);
if (braki.length) {
  console.log('');
  console.log(`!! PUSTE: ${braki.join(' i ')} — narzedzia zwroca blad do czasu uzupelnienia.`);
  console.log(`   Uzupelnij w: ${configPath}`);
  console.log('   Potem zrestartuj Claude Desktop.');
  // Kod wyjscia 3, zeby instalator NIE zameldowal „gotowe" na polowicznej
  // konfiguracji. Wpis w pliku zostaje — brakuje tylko wartosci.
  process.exit(3);
}
