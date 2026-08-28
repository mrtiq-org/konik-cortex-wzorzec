# Branding wdrożenia u klienta

Co jest nasze, co jest cudze i gdzie przebiega granica.

## Zasada

Brandujemy **to, co tworzymy** — vault, treści, głos asystenta, portal.
NIE przerabiamy **cudzych aplikacji**. Obsidian i Claude Desktop zostają sobą:
ich ikona w Docku, nazwa i ekran startowy są ich.

Obsidian jest darmowy także do zastosowań komercyjnych (sprawdzone
2026-08-18 na obsidian.md/license), więc wdrożenie u klienta nie wymaga
licencji. To jednak zgoda na UŻYWANIE, nie na repackaging — przerobienie
aplikacji i podanie jej jako naszej to osobna sprawa prawna, której nie
otwieramy. Nie ma takiej potrzeby: rzeczy, które klient widzi codziennie,
i tak są nasze.

## Co jest w naszych barwach

**Motyw vaulta** — `.obsidian/snippets/konik.css` + `appearance.json`.
Vault otwiera się w palecie portalu: Cyber Teal `#18B2A6` jako akcent,
Deep Void `#111111` na typografii, biel jako tło. Kolory są 1:1 z
`dashboard/src/index.css`, więc panel i vault wyglądają jak jeden produkt.

Magenta `#F229AF` celowo NIE jest używana na nawigacji. W portalu znaczy
„musisz podjąć decyzję" — gdyby świeciła na każdym folderze, przestałaby
znaczyć cokolwiek.

To jest zwykła konfiguracja użytkownika Obsidiana, nie modyfikacja
aplikacji. Klient może ją wyłączyć jednym kliknięciem i nic się nie psuje.

**Podpis w panelu bocznym** — „KONIK · Drugi Mózg", wyszarzony, nad listą
zakładek. Widoczny przy każdym otwarciu, nie krzyczy.

**Struktura i treść** — 11 folderów, 5 szablonów, 10 promptów, procedury.
To jest właściwy produkt i jest w całości nasz.

**Głos asystenta** — `.claude/output-styles/konkret.md` i `.claude/CLAUDE.md`.
Najmocniejsze brandowanie w całym wdrożeniu: klient codziennie rozmawia
z asystentem, który odpowiada w NASZYM stylu — od wniosku, krótko, ze
wskazaniem źródła. Tego konkurencja nie skopiuje ze zrzutu ekranu.

**Nazwa serwera MCP** — w Claude widoczna jako `konik-portal`.

**Strona startowa** — `00-START/Mapa Firmy.md` z nagłówkiem
„<Firma> — Drugi Mózg".

## Czego nie brandujemy

| Element | Dlaczego |
|---|---|
| Ikona i nazwa Obsidiana w Docku | repackaging cudzej aplikacji |
| Ekran startowy Obsidiana | j.w. |
| Claude Desktop | j.w. |
| Ikona Claude'a | j.w. |

## Nazwa katalogu vaulta

Obsidian pokazuje nazwę FOLDERU w tytule okna i w przełączniku vaultów.
Dlatego instalujemy do katalogu nazwanego `Drugi Mózg — <Firma>`, a nie
`vault` czy `Drugi-Mozg`:

```bash
./instalator/instaluj.sh "Cemet" ~/"Drugi Mózg — Cemet" "Anna Nowak"
```

Klient widzi wtedy „Drugi Mózg — Cemet" za każdym razem, gdy przełącza okno.

## Sprawdzenie po instalacji

1. Obsidian → Ustawienia → Wygląd → *Fragmenty CSS* — `konik` ma być włączony
2. Kolor akcentu: teal, nie fioletowy (domyślny Obsidiana)
3. Nad zakładkami widnieje podpis „KONIK · Drugi Mózg"

Gdy motywu nie widać: Obsidian czyta `.obsidian/` przy otwieraniu vaulta.
Zamknij i otwórz vault ponownie.
