#!/usr/bin/env node
// ============================================
// KONIK Cortex · lint-rodo — dane osobowe nie wchodzą do vaulta. Nigdy.
//
// Skanuje wszystkie .md vaulta pod kątem: PESEL (11 cyfr Z POPRAWNĄ sumą
// kontrolną — samo \d{11} łapałoby numery faktur), polskich telefonów
// (+48… lub 3×3 cyfry z separatorami) i adresów e-mail. Znalezisko = exit 1
// z listą plik:linia — pre-commit blokuje zapis.
//
// Świadomy wyjątek: linia zawierająca znacznik `rodo:ok` jest pomijana —
// do przykładów szkoleniowych i fikcyjnych danych demo. Wyjątek jest widoczny
// w treści notatki, więc nie da się go nadużyć po cichu.
//
// Zero zależności. Uruchomienie: node lint-rodo.js [katalog-vaulta]
// ============================================

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(process.argv[2] || '.');
const SKIP_DIRS = new Set(['.git', '.obsidian', 'node_modules']);

const RE_EMAIL = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
const RE_PHONE = /(?:\+48[ -]?\d{3}[ -]?\d{3}[ -]?\d{3})|(?:\b\d{3}[ -]\d{3}[ -]\d{3}\b)/g;
const RE_PESEL_CAND = /\b\d{11}\b/g;

function isValidPesel(s) {
  const w = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3];
  const sum = w.reduce((acc, wi, i) => acc + wi * Number(s[i]), 0);
  return (10 - (sum % 10)) % 10 === Number(s[10]);
}

function* mdFiles(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      if (!SKIP_DIRS.has(entry.name)) yield* mdFiles(path.join(dir, entry.name));
    } else if (entry.name.toLowerCase().endsWith('.md')) {
      yield path.join(dir, entry.name);
    }
  }
}

const findings = [];
for (const file of mdFiles(ROOT)) {
  const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
  lines.forEach((line, i) => {
    if (line.includes('rodo:ok')) return;
    const rel = path.relative(ROOT, file);
    for (const m of line.matchAll(RE_EMAIL)) {
      findings.push(`${rel}:${i + 1} — adres e-mail: ${m[0]}`);
    }
    for (const m of line.matchAll(RE_PHONE)) {
      findings.push(`${rel}:${i + 1} — numer telefonu: ${m[0]}`);
    }
    for (const m of line.matchAll(RE_PESEL_CAND)) {
      if (isValidPesel(m[0])) findings.push(`${rel}:${i + 1} — PESEL: ${m[0]}`);
    }
  });
}

if (findings.length) {
  console.error('✗ Dane osobowe w vaulcie (Kontrakt Danych: kontakt żyje w CRM, tu tylko crm_id):');
  for (const f of findings) console.error('  ' + f);
  console.error(`\nRazem: ${findings.length}. Usuń dane albo — wyłącznie dla fikcyjnych przykładów — dopisz w tej linii znacznik rodo:ok.`);
  process.exit(1);
}
console.log('✓ lint-rodo: czysto');
