# Skaner bts

**Skaner btsr** program umożliwiający analizę plików CSV. Dzięki temu narzędziu możesz filtrować dane według wybranych kolumn, ignorować niepotrzebne kolumny oraz wyświetlać tylko te linie, które spełniają określone przez Ciebie kryteria. Program jest napisany w języku **C** przy użyciu narzędzia **Flex** do analizy leksykalnej.

## Funkcje programu

- Wczytanie pliku CSV do pamięci.
- Interaktywne dodawanie filtrów na podstawie zawartości kolumn.
- Możliwość ignorowania określonych kolumn podczas wyświetlania wyników.
- Filtrowanie i wyświetlanie tylko tych linii, które spełniają zadane kryteria.
- Wyświetlanie numerów linii, które pasują do filtrów.

## Wymagania

Aby skompilować i uruchomić program, będziesz potrzebować:

- **Flex** (do analizy leksykalnej plików CSV).
- **GCC** (kompilator C).
- **Make** (opcjonalnie, do automatyzacji procesu kompilacji).

## Kompilacja

Z użyciem Makefile

```bash
make
```

Manualnie

```bash
flex bts.l
gcc -o bts lex.yy.c string_array.c -lfl
```

## Uruchomienie

```bash
./bts <plik.csv>
```

Jeśli nie podasz nazwy pliku jako argumentu, program poprosi Cię o wprowadzenie nazwy pliku

```bash
Brak nazwy pliku. Proszę podać nazwę pliku CSV: <plik.csv>
```

Po wczytaniu pliku, program umożliwi dodanie filtrów. Filtry pozwalają na wybór, które linie danych mają być wyświetlane, w zależności od wartości w danej kolumnie.
Możesz dodać dowolną liczbę filtrów, powtarzając te kroki. Aby zakończyć dodawanie filtrów, wpisz liczbę ujemną:

eg.
Wyświetlone zostaną tylko wiersze z ID równym 3.

```bash
Wprowadź filtry (wpisz '-1', aby zakończyć):
Możliwe wartości:
0: Godzina
1: Data
2: Id
...

<numer kolumny>: 2
<wartość>: 3
```

Po każdym wprowadzeniu danych wyświetlane są aktywne filtry

```bash
--------------------------
Aktywne filtry:
Id: 3
--------------------------
```

- Program porównuje wartość w danej kolumnie (np. "ID") z wartością podaną w filtrze (np. "3"). Jeśli wartość w wierszu jest różna od wartości filtra, wiersz jest pomijany.
- Tylko te wiersze, które spełniają wszystkie filtry (tj. mają odpowiednią wartość w każdej filtrującej kolumnie), zostaną wyświetlone.

## Ignorowanie kolumn

Po dodaniu filtrów, program umożliwi Ci wybranie kolumn, które mają zostać zignorowane podczas wyświetlania wyników.
Możesz wybrać więcej niż jedną kolumnę. Aby zakończyć wybieranie kolumn do zignorowania, wpisz liczbe ujemną:

```bash
Podaj kolumny do ignorowania (wpisz '-1', aby zakończyć):
Możliwe wartości:
0: Godzina
1: Data
2: Id
...

<numer kolumny>: 2
```

## Końcowy wynik

Po zakończeniu analizy pliku, program wyświetli liczbę dopasowanych linii oraz ich indeksy.

```bash
Dopasowano: 2
6, 60
```

Dla każdego wiersza, który spełnia wszystkie aktywne filtry, program wyświetla szczegółowe informacje o tym wierszu. Wyświetlane są:

- Numer wiersza w pliku.
- Nazwy kolumn, które zostały wybrane do wyświetlenia (po wcześniejszym przetwarzaniu, gdy użytkownik wybrał kolumny do wyświetlenia).
- Wartości z odpowiednich kolumn w bieżącym wierszu.

```bash
----------------------------
Wiersz nr: 6
Godzina: 08:55:05
Data: 18.10.2024
Dlugosc geogr.: 20,83282
Szerokosc geogr.: 50,24633
Nr inicjujacy: 501501503
Nr odbierajacy: 668662891
Czas polaczenia:
Rodzaj polaczenia: SMS
Kierunek: 360
----------------------------
----------------------------
Wiersz nr: 60
Godzina: 15:55:05
Data: 19.10.2024
Dlugosc geogr.: 20,83282
Szerokosc geogr.: 50,24633
Nr inicjujacy: 501501501
Nr odbierajacy: 601662891
Czas polaczenia:
Rodzaj polaczenia: SMS
Kierunek: 360
----------------------------
```
