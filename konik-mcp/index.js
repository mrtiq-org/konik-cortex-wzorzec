#!/usr/bin/env node
// ============================================
// konik-mcp v0.1 — Claude klienta czyta swój portal KONIK.
//
// READ-ONLY z założenia: v1 nie wykonuje żadnej akcji w systemie KONIK.
// Zapis (akceptacje, komentarze) = v2, po pilocie i decyzji o modelu auth.
//
// Konfiguracja (env, ustawiane przez instalator w konfigu Claude Desktop):
//   KONIK_API_URL   — domyślnie https://dev.koniksystems.com
//   KONIK_TOKEN     — JWT klienta z panelu (⚠️ v1: token wygasa; po wygaśnięciu
//                     narzędzia zwracają czytelny błąd z instrukcją odnowienia —
//                     nie ciche pustki. Model docelowy: decyzja 6 CORTEX-PLAN.md)
//   KONIK_CLIENT_ID — id konta (x-client-id, backend wiąże z sub tokenu)
// ============================================

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const API = (process.env.KONIK_API_URL || 'https://dev.koniksystems.com').replace(/\/$/, '');
const TOKEN = process.env.KONIK_TOKEN;
const CLIENT_ID = process.env.KONIK_CLIENT_ID;

async function konikGet(path) {
  if (!TOKEN || !CLIENT_ID) {
    throw new Error('Brak KONIK_TOKEN / KONIK_CLIENT_ID w konfiguracji serwera MCP.');
  }
  const res = await fetch(`${API}${path}`, {
    headers: {
      Authorization: `Bearer ${TOKEN}`,
      'x-client-id': CLIENT_ID,
      'Content-Type': 'application/json',
    },
  });
  if (res.status === 401) {
    throw new Error('Sesja KONIK wygasła — zaloguj się w portalu i zaktualizuj KONIK_TOKEN w konfiguracji.');
  }
  const data = await res.json().catch(() => ({}));
  if (!res.ok || data?.success !== true) {
    throw new Error(`KONIK API ${res.status}: ${data?.error?.message ?? 'nieznany błąd'}`);
  }
  return data.data;
}

const asText = (obj) => ({ content: [{ type: 'text', text: JSON.stringify(obj, null, 2) }] });
const asError = (e) => ({
  content: [{ type: 'text', text: `Błąd: ${e instanceof Error ? e.message : String(e)}` }],
  isError: true,
});

const server = new McpServer({ name: 'konik-portal', version: '0.1.0' });

const TOOLS = [
  ['portal_przeglad', 'Pulpit portalu KONIK: tryb (wdrożenie/obsługa), etapy prac, „czego potrzebujemy od Ciebie", zużycie miesiąca, najbliższe spotkanie.', '/api/portal/overview'],
  ['akceptacje', 'Materiały czekające na akceptację klienta w portalu KONIK, z licznikiem SLA 48 h. Akceptować można wyłącznie w portalu — ten serwer tylko czyta.', '/api/portal/approvals'],
  ['kalendarz_publikacji', 'Kalendarz publikacji na najbliższe 2 tygodnie (zaplanowane i opublikowane materiały).', '/api/panel/calendar'],
  ['dokumenty_marki', 'Dokumenty marki (Tone of Voice, Key Visual, harmonogramy) oraz niemutowalna historia podpisanych decyzji.', '/api/portal/documents'],
  ['drugi_mozg', 'Stan wdrożenia Drugiego Mózgu (KONIK Cortex): etapy, checklista odbioru, kurator, przeglądy, backup, wersje komponentów.', '/api/portal/cortex'],
];

for (const [name, description, path] of TOOLS) {
  server.tool(name, description, {}, async () => {
    try {
      return asText(await konikGet(path));
    } catch (e) {
      return asError(e);
    }
  });
}

const transport = new StdioServerTransport();
await server.connect(transport);
