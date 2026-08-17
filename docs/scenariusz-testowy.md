# Scenariusz testowy end-to-end — „suchy pilot" (fikcyjny klient: Bosman Wnętrza)

Grasz obie role: PM-a i klienta. Czas: ~60–90 min. Dane poniżej są fikcyjne
i gotowe do wklejenia. Cel: przejść CAŁY proces wdrożenia i złapać zgrzyty,
zanim zobaczy je prawdziwy klient.

**Legenda klienta testowego:** Bosman Wnętrza sp. z o.o., Gdańsk — stolarnia
premium (meble na wymiar do jachtów i apartamentów), 14 osób, ścieżka TEAM
(testujemy silnikiem plikowym). Kurator: Anna Bosman, Office Manager.

---

## AKT 1 — Portal (rola: PM) · dzień 0

1. Zaloguj się na `dev.koniksystems.com` swoim kontem staff.
2. Sidebar, dół → „— Wejdź jako klient —" → **konto testowe** (nigdy realny klient).
3. `/panel/drugi-mozg` → „Uruchom wdrożenie (opiekun)" → **TEAM**.
4. Odhacz „Rozmowa kwalifikacyjna" → data serwera na osi. ✅
5. Kontrtest bramki: spróbuj odhaczyć „Budowa systemu" — ma odbić
   (etapy tylko po kolei). ✅

## AKT 2 — Instalacja u „klienta" (rola: PM na maszynie klienta) · dzień 4

```powershell
powershell -File "C:\Users\wikto\konik-cortex-wzorzec\instalator\instaluj.ps1" `
  -Firma "Bosman Wnętrza" -Cel "C:\Vaulty\Bosman" -Kurator "Anna Bosman"
```

Sprawdź: 5 kroków bez błędu, na końcu commit „Start Drugiego Mozgu".
Otwórz `C:\Vaulty\Bosman` w Obsidianie (Open folder as vault; Templates →
`08-SZABLONY`) — Mapa Firmy ma mówić „Bosman Wnętrza", nie `{{FIRMA}}`. ✅

## AKT 3 — Claude na vaulcie (rola: pracownik klienta)

`cd C:\Vaulty\Bosman; claude`

**Test 1 — pytanie o procedurę:**
> Jak u nas wygląda wdrożenie nowego pracownika?

Oczekiwane: kroki z SOP-01 + wskazane źródło (nazwa notatki). ✅

**Test 2 — notatka ze spotkania (wklej PONIŻSZE po `/notatka-ze-spotkania`):**
> Spotkanie z klientem Marina Yacht Club, 2026-08-12. Ustaliliśmy: zabudowa
> mesy w dębie bielonym, 3 kabiny, termin do końca listopada. Pan Nowak
> (tel. 501 234 567, j.nowak@marinayc.pl) prosi o kontakt tylko po 16:00.
> Decyzja: dajemy 8% rabatu przy płatności 50/50. Zadanie: Marek wysyła
> wycenę do piątku. Uwaga: klient nie znosi maili dłuższych niż 5 zdań.

Oczekiwane: notatka w `02-SPOTKANIA/2026/`, decyzja o rabacie osobno
w `05-DECYZJE`, zadanie oznaczone „do CRM", **telefon i mail USUNIĘTE**
(zastąpione rolą/crm_id), preferencje klienta zachowane. ✅

**Test 3 — nowa procedura (`/nowa-procedura`):** odpowiedz na pytania Claude'a
danymi: reklamacja mebla → zgłoszenie mailem od klienta → Anna rejestruje
w 24h → oględziny u klienta w 5 dni roboczych (Marek) → naprawa w warsztacie
do 14 dni → wyjątek: rysy powierzchniowe naprawiamy u klienta od ręki →
najczęstszy błąd: obiecywanie terminu przed oględzinami.
Oczekiwane: `SOP-02 Reklamacja mebla` w `01-PROCEDURY/Operacje`, status
`szkic`, każdy krok ma właściciela. ✅

**Test 4 — ochrona procedur:** poproś „zmień w SOP-01 dzień 5 na dzień 3".
Oczekiwane: propozycja diffa, BEZ zapisu. ✅

**Test 5 — RODO w commicie:** utwórz notatkę z tekstem
`Kandydat Jan Kowalski, PESEL 44051401359` →
`git add . ; git commit -m "test"` → commit ZABLOKOWANY z plik:linia.
Usuń → przechodzi. ✅

**Test 6 — Obsidian widzi pracę Claude'a:** otwórz Obsidiana — notatka
z Testu 2 jest w drzewie; kliknij, sprawdź frontmatter. ✅

## AKT 4 — Odbiór w portalu (rola: PM) · dzień 10

1. Wróć do portalu (impersonacja na klienta testowego) → `/panel/drugi-mozg`.
2. Odhaczaj etapy po kolei do „Rytuały" włącznie.
3. Kontrtest BRAMKI 2: „Odbiór" przy niepełnej checkliście = „Wstrzymane". ✅
4. Odhacz 14/14 pozycji checklisty (przechodząc je REALNIE na vaulcie Bosman —
   to jest ćwiczenie protokołu odbioru) → „Odbiór" przechodzi → plakietka
   **„Obsługa"**. ✅
5. Formularz PM: Kurator „Anna Bosman / Office Manager", data przeglądu +30 dni,
   „Odnotuj kopię zapasową". ✅
6. Zakończ impersonację → wejdź jako klient → wszystko widoczne, ZERO przycisków. ✅

## AKT 5 — Pomiar (to, po co robimy suchy pilot)

Zapisz czasy: instalacja ___ min · migracja+SOP ___ h · testy Claude ___ min ·
odbiór ___ min. Porównaj z założeniem TEAM = 12h czasu PM (tu robisz wycinek —
liczy się proporcja). Każdy zgrzyt (komunikat po angielsku, niejasny krok,
błąd) → wpis do listy poprawek wzorca v1.1.

## Czego ten test NIE pokrywa (świadomie)

Notion/TEAM realny (odwzorowanie baz) · Sejf/Ollama · konto Claude zakładane
na kartę klienta · warsztat z żywymi ludźmi · konik-mcp u klienta (osobny test
w konik-mcp/README).
