# Cortex — roadmapa ulepszeń v1.0 (2026-08-13)

Zasada doboru: każda pozycja musi wzmacniać jedną z trzech dźwigni —
**retencję** (klient widzi żywy system), **marżę** (mniej godzin PM na klienta),
**sprzedaż** (nowy argument na demo). Pomysły bez dźwigni odpadły.

## A. Codzienna wartość dla pracowników klienta (dźwignia: retencja)

| # | Co | Po co | Koszt |
|---|---|---|---|
| A1 | **Podgląd ekstrakcji przed zapisem** — po analizie głosówki klient widzi „co zamierzam zapisać" (notatka/zadania/wydarzenie) i może poprawić lub odrzucić, ZANIM poleci do Notion | Zaufanie do automatu buduje się kontrolą; jedna zła notatka bez podglądu = klient wyłącza moduł | 1–2 dni |
| A2 | **Upload nagrania z pliku** — obok mikrofonu przycisk „wgraj nagranie" (dyktafon, WhatsApp voice, nagranie ze spotkania online) | Realne rozmowy częściej JUŻ SĄ nagrane niż nagrywane na żywo | 0,5 dnia (tor uploadu istnieje) |
| A3 | **Digest tygodniowy e-mailem** — „co nowego w Waszym Drugim Mózgu": nowe procedury, decyzje tygodnia, co czeka na przegląd | Buduje nawyk zaglądania; martwa baza umiera po cichu, digest robi z niej rytm firmy | 1 dzień (SendGrid wpięty) |
| A4 | **Tryb spotkaniowy** — dłuższe nagrania (60–90 min) + oznaczanie „kto mówi" w transkrypcji | Otwiera use-case „nagraj całe spotkanie zarządu"; dziś limit 30 min i jeden głos | ~tydzień (diarization) |
| A5 | **Okno „zapytaj bazę" w portalu/PWA** — pracownik bez Claude'a na komputerze pyta z telefonu, odpowiedź ze źródłem | Dziś pytania wymagają Claude'a; to daje WSZYSTKIM pracownikom dostęp z kieszeni | duże (~2 tyg.; koszty tokenów na budżet tenanta — wymaga decyzji cennikowej) |

## B. Wartość dla właściciela (dźwignia: retencja + uzasadnienie abonamentu)

| # | Co | Po co | Koszt |
|---|---|---|---|
| B1 | **Raport Wartości automatyczny** — licznik głosówek/pytań/nowych SOP-ów, czas od ostatniego przeglądu, najaktywniejsze osoby; widok w zakładce + kwartalny PDF | Dziś Raport Wartości (+90) jest ręczny. Liczby na ekranie to kotwica retencji nr 1: właściciel WIDZI, za co płaci | 2–3 dni (eventy już logujemy) |
| B2 | **Wskaźnik zdrowia bazy (0–100)** — świeżość procedur, pokrycie właścicielami, aktywność zespołu; jedna liczba w portalu, wspólna dla PM i klienta | Zamienia „opiekę nad bazą" z obietnicy w metrykę; spadek = konkretna rozmowa PM | 1–2 dni |
| B3 | **Mapa luk wiedzy** — miesięczny raport AI: pytania bez odpowiedzi w bazie, procedury sprzeczne, obszary bez właściciela → gotowa agenda przeglądu kuratora | Przegląd miesięczny przestaje zależeć od sumienności kuratora — system sam podaje agendę | 2 dni (na TEAM od razu; LOCAL po A5) |

## C. Operacyjnie dla KONIK (dźwignia: marża / skala PM-ów)

| # | Co | Po co | Koszt |
|---|---|---|---|
| C1 | **Heartbeat backupu** — vault sam raportuje wykonany snapshot do API portalu; brak sygnału >48 h = alarm dla PM | Dziś PM klika „odnotuj backup" ręcznie = dane deklaratywne. Automat robi z SLA fakt | 1 dzień |
| C2 | **Telemetria wersji** — instalator/vault zgłasza wersje komponentów do rejestru w portalu | Rejestr wersji per klient aktualizuje się sam; aktualizacja po regresji = jedna lista, nie obdzwanianie | 1 dzień |
| C3 | **Szablon Notion do duplikacji** — wzorcowy workspace TEAM budowany RAZ, u klienta „Duplicate" | Skraca budowę TEAM z godzin do minut — bez tego TEAM nie zejdzie do 12 h PM | 1 dzień pracy + utrzymanie |
| C4 | **Kreator konfiguracji Notion** — zamiast 4 pól z ID: przycisk „połącz Notion" (OAuth) + auto-utworzenie 4 baz przez API | Wpisywanie ID z URL-i to najsłabszy moment wdrożenia (dziś przerabialiśmy to na sobie) | 2–3 dni |

## D. Sprzedażowo (dźwignia: nowe argumenty / segmenty)

| # | Co | Po co | Koszt |
|---|---|---|---|
| D1 | **Zadania z głosówki → CRM klienta** (webhook/integracja zamiast bazy zadań w Notion) | Domyka spójność z Kontraktem Danych („zadania żyją w CRM") i otwiera integrację, o którą zapyta każda firma z CRM-em | 2–3 dni per CRM (zacząć od webhooka generycznego) |
| D2 | **Wydarzenia → Kalendarz Google** — prawdziwe zaproszenia z powiadomieniami, nie tylko wiersz w Notion | „Umówiliśmy spotkanie w rozmowie → jest w kalendarzu z zaproszeniami" — mocny moment demo | 2 dni |
| D3 | **Ekstrakcja wielojęzyczna** (EN/DE) | Firmy eksportowe (BBHM, Perca) rozmawiają z partnerami po angielsku/niemiecku | 0,5 dnia (Whisper już umie; prompt + testy) |
| D4 | **Sejf jako usługa** — mini-PC z Ollamą postawiony i monitorowany przez nas | DUAL przestaje wymagać IT po stronie klienta → poszerza rynek ścieżki premium | duże (sprzęt, logistyka — po pilocie) |

## Rekomendowana kolejność (pierwszy sprint ulepszeń, ~1 tydzień)

1. **A1 podgląd przed zapisem** — bez tego zaufanie do Głosówki wisi na jakości
   jednej ekstrakcji; to jest bezpiecznik całego modułu.
2. **B1 Raport Wartości automatyczny** — retencja; dane już są, brakuje widoku.
3. **A2 upload z pliku + D3 wielojęzyczność** — dwa tanie rozszerzenia zasięgu.
4. **C1 heartbeat backupu** — zamienia deklarację w pomiar (jakość przed szybkością).

Drugi rzut (po pilocie na Interkoordynacjach): C3+C4 (skrócenie wdrożenia TEAM),
B2+B3 (zdrowie bazy), D1+D2 (integracje). A5 i D4 — dopiero z decyzją cennikową,
bo niosą stały koszt jednostkowy.

## E. Integracje z narzędziami klienta (dźwignia: sprzedaż modułowa + adopcja)

Rama: każda integracja = **osobno wyceniany moduł dosprzedażowy** (jak Głosówka
rozszerzyła TEAM), nie darmowy dodatek. Kolejność wg (ilu klientów skorzysta ÷ koszt).

| # | Integracja | Co daje klientowi | Koszt / zależności |
|---|---|---|---|
| E1 | **Kalendarz Google / Outlook** | Wydarzenie z głosówki = PRAWDZIWE zaproszenie z powiadomieniami i uczestnikami, nie wiersz w Notion | średni; wymaga OAuth-app KONIK w Google Cloud (klucz zakłada CTO) + zgody klienta przy wdrożeniu |
| E2a | **Slack / Teams — powiadomienia** | „Nowa notatka ze spotkania" wpada na kanał — zespół widzi, że baza żyje | tani (webhook przychodzący, zero OAuth) |
| E2b | **Slack / Teams — bot pytań** | `@Mózg jak robimy reklamacje?` na kanale → odpowiedź ze źródłem; każdy pracownik pyta bazę bez instalowania czegokolwiek | średni; koszt tokenów na budżet tenanta |
| E3a | **Wejście e-mail** (`mozg@…`) | Forward maila → notatka z podsumowaniem; zero nowych nawyków | tani (mamy SendGrid; inbound parse) |
| E3b | **Wejście WhatsApp** | Głosówka wysłana na numer firmowy = to samo co mikrofon w portalu; kulturowo naturalne dla polskiego MŚP | średni (WhatsApp Business API + koszty Meta) |
| E4 | **Google Meet / Teams / Zoom** | System sam zaciąga nagrania spotkań i robi notatki — „autopilot pamięci", zero wysiłku po wdrożeniu | drogi (OAuth + polling nagrań per platforma) |
| E5 | **CRM klienta: HubSpot / Pipedrive / Livespace** | Zadania i kontakty z rozmów → tam, gdzie żyją wg Kontraktu Danych (domyka niespójność D1) | średni per CRM; zacząć od systemu, który wskaże pilot |
| E6 | **Google Drive / OneDrive** | Automatyczne linkowanie plików źródłowych + strażnik nowych dokumentów (nowy cennik → propozycja aktualizacji wiedzy) | średni; klient Google Drive już jest w platformie (archiwum ofert) |
| E7 | **Telefon / voicebot** | „Zadzwoń i podyktuj" — dla ludzi, którzy nie otworzą żadnej aplikacji; spina Cortex z voicebotami z portfolio KONIK | drogi; po pilocie, jako moduł premium |

Rekomendowana kolejność: **E1 → E2a → E3a → E2b → E4**; E5 przy pilocie
(konkretny CRM), E3b/E7 jako moduły premium po walidacji popytu.

Warunek wejścia dla E1 (pierwszej w kolejce): projekt OAuth w Google Cloud
Console (client ID + secret, scope `calendar.events`) — zakłada CTO na koncie
Grupy; bez tego nie ma czego kodować.

## F. Nowe wejścia pamięci (dźwignia: adopcja — „wszystko trafia do systemu")

| # | Co | Wartość | Koszt |
|---|---|---|---|
| F1 | **Zdjęcie → wiedza**: fotka tablicy po naradzie / papierowego dokumentu → vision (mamy w anthropic_client) → ekstrakcja → Notion | Narady przy tablicy to najczęstsza NIEZAPISYWANA wiedza w MŚP | 2–3 dni (tor jak Głosówka, bez Whispera) |
| F2 | **Import historii**: „wrzuć folder ofert/protokołów z 5 lat" → masowe indeksowanie → seed bazy | Dzień 4–7 wdrożenia krótszy; baza od startu pełna, nie pusta | ~tydzień (kolejka + koszty tokenów na budżet) |
| F3 | **Notatka tekstowa szybka** — pole „zapisz myśl" w PWA (bez nagrywania) | Nie każdy chce mówić; tekst to ten sam łańcuch minus Whisper | 0,5 dnia |

## G. Inteligencja NAD pamięcią (dźwignia: retencja — system, który sam się odzywa)

| # | Co | Wartość | Koszt |
|---|---|---|---|
| G1 | **Pamięć tygodnia** — piątkowe podsumowanie: co ustaliliśmy, jakie decyzje, które zadania z głosówek wiszą bez terminu | Właściciel widzi tydzień firmy w 2 minuty; naturalny nośnik digestu (A3) | 2 dni |
| G2 | **Przypomnienia z obietnic** — zadanie z terminem z głosówki → dzień przed: ping na Slack/webhook („obiecaliście wycenę do piątku") | Zamienia notatki w egzekucję — najczęstsza skarga MŚP to „ustaliliśmy i umarło" | 2 dni (dane już są) |
| G3 | **Strażnik sprzeczności** — nowa głosówka przeczy wcześniejszej decyzji → alert do kuratora | Baza, która sama pilnuje spójności = argument demo nie do podrobienia | 3–4 dni |
| G4 | **Brief przed spotkaniem** — wydarzenie w kalendarzu (E1) → rano automatyczne „wszystko, co wiemy o tym kliencie" | Domyka pętlę: rozmowa→pamięć→następna rozmowa | 2 dni, wymaga E1 |

## H. Portal jako pełny produkt (dźwignia: sprzedaż + niezależność od Notion)

| # | Co | Wartość | Koszt |
|---|---|---|---|
| H1 | **Feed „Pamięć firmy"** w portalu — przegląd notatek/decyzji z głosówek bez wchodzenia do Notion | Portal przestaje być tylko pilotem — staje się czytnikiem pamięci; krok do wariantu bez Notion | 2–3 dni |
| H2 | **Konta pracowników** — dziś jedno konto klienta; głosówki per osoba z podpisem „kto nagrał" | Warunek realnego użycia zespołowego i rozliczalności | duże (auth multi-user per tenant) |
| H3 | **Limity pakietowe** — `packageLimits` w portalu przestaje być `null`: licznik głosówek/tokenów vs pakiet | Podstawa cennika modułowego i rozmowy o upsellu | 2 dni + decyzja cennikowa |

Kolejność rekomendowana po sprincie 1: **G2 → F3 → G1 → H1 → F1**; H2/H3 razem
z decyzjami cennikowymi; G3/G4 po E1.

## I. Integracje — druga runda (2026-08-13)

| # | Co | Wartość | Koszt |
|---|---|---|---|
| I1 | **SMS (SMSAPI — już wpięte w panel)** | Przypomnienia G2 i alerty SMS-em do właściciela bez Slacka; dla mikrofirm naturalniejszy kanał niż komunikatory | dni (infra jest) |
| I2 | **E-mail (SendGrid — już wpięty)** | Powiadomienia + tygodniowy digest mailem; zerowy próg, działa u każdego od 1. dnia | dni (infra jest) |
| I3 | **Uniwersalny webhook wychodzący (Make/Zapier)** | Zdarzenia Cortexa (`glosowka.done`, `zadanie.termin`, `decyzja.nowa`) → klient spina z tysiącami aplikacji bez naszego kodu; jedna integracja zastępuje pół roadmapy | ~tydzień |
| I4 | **Telefonia VoIP (CloudTalk, Zadarma, 3CX)** | Centralka nagrywa rozmowy handlowe → webhook po połączeniu → każda rozmowa SAMA wpada w łańcuch Głosówki. „Pamięć, która pisze się sama" — najmocniejsze demo dla firm żyjących z telefonu | duży (moduł premium, po pilocie) |
| I5 | **Fakturownia / inFakt / wFirma** | „Wystaw fakturę za X" z głosówki + kontekst płatności w briefie przed spotkaniem | średni per system |
| I6 | **KSeF** | Obowiązkowe e-faktury — asystent widzący faktury to pytanie każdej księgowej; hak PL, którego nie ma zachodnia konkurencja | średni/duży |
| I7 | **Baselinker** | E-commerce: zamówienia jako kontekst wiedzy o klientach | średni |
| I8 | **Integracje WEWNĘTRZNE KONIK** — głosówka „zrób z tego post" → content engine; „przygotuj ofertę na to, co ustaliliśmy" → generator ofert z rejestrem; po RODO-sprincie zadania → CRM KONIK | Przewaga nie do skopiowania: pamięć firmy + maszyna, która na niej WYKONUJE marketing i sprzedaż. Właściwa odpowiedź na „czym się różnicie od Notion AI" | etapami; strategiczne |

Kolejność: **I2+I1 → I3 → I4 → I8**; I5–I7 wg popytu z pilotów.

## Czego świadomie NIE dodajemy

- **Czat AI wewnątrz Notion/Obsidiana wtyczkami** — łamie zasadę zamrożonych
  wersji i jednej warstwy inteligencji (Claude).
- **Własna apka natywna w App Store** — PWA pokrywa potrzebę; natywna wraca
  na stół dopiero, gdy klienci zaczną prosić o powiadomienia push na iOS.
- **Automatyczna edycja procedur przez AI** — SOP zmienia człowiek; to jest
  bezpiecznik zaufania, nie brak funkcji.
