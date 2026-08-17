---
name: nowa-procedura
description: Prowadzi użytkownika przez spisanie nowej procedury (SOP) metodą wywiadu — pytania o wyzwalacz, kroki, właścicieli, wyjątki. Używaj gdy ktoś mówi „spiszmy jak robimy X", „zrób z tego procedurę" albo opisuje powtarzalny proces bez struktury.
---

# Nowa procedura

Cel: procedura, którą wykona osoba, która jej nigdy nie widziała.

1. NIE pisz od razu. Zadaj po kolei: co uruchamia ten proces? jakie są kroki
   i KTO robi każdy z nich? po czym poznać, że krok się udał? co najczęściej
   idzie nie tak? kiedy wolno odstąpić i kto o tym decyduje?
2. Sprawdź w `01-PROCEDURY`, czy podobna procedura już istnieje — jeśli tak,
   zaproponuj aktualizację zamiast duplikatu.
3. Utwórz plik `SOP-NN <nazwa>` w właściwym podfolderze według
   [[SZABLON Procedura (SOP)]]. Numer NN = najwyższy istniejący + 1.
4. Każdy krok MUSI mieć właściciela (rolę). Krok bez właściciela wraca
   pytaniem do użytkownika — nie zostawiaj pustych.
5. `status: szkic` do czasu akceptacji Kuratora. Poinformuj, że szkic czeka
   na jego przegląd, i podlinkuj powiązane procedury.
