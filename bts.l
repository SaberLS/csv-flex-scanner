%{
// bts.l
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "string_array.h"

#define MAX_COLUMNS 100        // Maksymalna liczba kolumn w pliku
#define MAX_FIELD_LENGTH 128   // Maksymalna długość pojedynczego pola

int column_count = 0;          // Licznik bieżących kolumn w linii
int column_amount = 0;         // Całkowita liczba kolumn w pliku
int line_count = 0;            // Licznik przetworzonych linii

int displayed_columns[MAX_COLUMNS]; // Tablica indeksów kolumn do wyświetlenia
int displayed_count = 0;            // Liczba kolumn do wyświetlenia

int match_count = 0;           // Licznik pasujących linii
int match_lines[MAX_COLUMNS];  // Tablica przechowująca numery pasujących linii

StringArray headers;           // Nagłówki kolumn
StringArray current_line;      // Dane bieżącej linii

// Struktura do przechowywania filtrów
struct filter {
    int column_I;                // Indeks kolumny, do której odnosi się filtr
    char value[MAX_FIELD_LENGTH]; // Wartość filtra
} filters[MAX_COLUMNS];

int filter_count = 0;          // Liczba aktywnych filtrów

// Funkcja dodająca nowy filtr
void addFilter(int column_I, char *value) {
    filters[filter_count].column_I = column_I; // Zapisanie indeksu kolumny
    strcpy(filters[filter_count].value, value); // Zapisanie wartości filtra
    filter_count++; // Zwiększenie licznika filtrów
}

// Funkcja pobierająca filtr od użytkownika
bool getFilter() {
    int column_I = -1;          // Indeks kolumny
    char value[MAX_FIELD_LENGTH]; // Wartość filtra

    printf("<numer kolumny>: ");
    scanf("%d", &column_I);
    if (column_I < 0) {         // Jeśli indeks < 0, kończymy pobieranie filtrów
        return false;
    }

    printf("<wartość>: ");
    scanf("%s", value);         // Wczytanie wartości od użytkownika

    addFilter(column_I, value); // Dodanie nowego filtra
    return true;
}

// Funkcja wyświetlająca aktywne filtry
void printActiveFilters() {
    printf("\n--------------------------\nAktywne filtry:\n");
    for (int i = 0; i < filter_count; i++) {
        printf("%s: %s\n", headers.strings[filters[i].column_I], filters[i].value); // Wyświetlanie nazwy kolumny i wartości
    }
    printf("--------------------------\n");
}

// Funkcja wyświetlająca nagłówki kolumn
void printHeaders() {
    for (int i = 0; i < column_amount; i++) {
        printf("%d: %s\n", i, headers.strings[i]); // Wyświetlanie numeru i nazwy kolumny
    }
    printf("\n");
}

// Funkcja czyszcząca dane bieżącej linii
void clean() {
    column_count = 0;          // Zerowanie licznika kolumn
    freeStringArray(&current_line); // Czyszczenie pamięci przypisanej do bieżącej linii
}

// Funkcja wyświetlająca dane bieżącej linii, jeśli spełnia filtry
void printCurrentLine() {
    match_lines[match_count] = line_count + 1; // Zapisywanie numeru pasującej linii (+1, ponieważ linie liczone od zera)
    match_count++; // Zwiększenie licznika pasujących linii

    printf("----------------------------\n");
    printf("Wiersz nr: %d\n", line_count + 1);
    for (int i = 0; i < displayed_count; i++) { // Wyświetlanie wybranych kolumn
        int displayedID = displayed_columns[i];
        printf("%s: %s\n", headers.strings[displayedID], current_line.strings[displayedID]);
    }
    printf("----------------------------\n");
}

// Funkcja sprawdzająca, czy linia spełnia aktywne filtry
bool checkLine() {
    for (int i = 0; i < filter_count; i++) {
        int column_I = filters[i].column_I;

        // Sprawdzenie, czy indeks filtra mieści się w zakresie kolumn
        if (column_I <= column_amount) {
            // Jeśli linia nie spełnia kryterium filtra, zwracamy false
            if (strcmp(current_line.strings[column_I], filters[i].value) != 0) {
                return false;
            }
        }
    }
    return true; // Linia spełnia wszystkie filtry
}

// Funkcja uzupełniająca puste miejsca w bieżącej linii
void fillEmptySapce(StringArray *arr) {
    while (column_count > (int)arr->size) { // Dodawanie pustych pól, jeśli ich brakuje
        addString(arr, " ");
    }
}

// Funkcja do wyboru ignorowanych kolumn przez użytkownika
int selectIgnoredColumns() {
    int column_I = -1;

    printf("<numer kolumny>: ");
    scanf("%d", &column_I);

    return column_I;
}

// Funkcja ignorująca wskazane kolumny
void IgnoreColumn(int column_I) {
    // Sprawdzanie, czy podany indeks znajduje się w tablicy kolumn do wyświetlenia
    for (int i = 0; i < displayed_count; i++) {
        if (displayed_columns[i] == column_I) {
            // Przesunięcie elementów w tablicy w celu usunięcia kolumny
            for (int j = i; j < displayed_count - 1; j++) {
                displayed_columns[j] = displayed_columns[j + 1];
            }
            displayed_count--; // Zmniejszenie liczby wyświetlanych kolumn
            break;
        }
    }
}

%}
FIELD [^;\n]+
SEPARATOR ;
ENDLINE \n

%%
{FIELD} { // Obsługa pola (ciągu znaków)
    char newString[MAX_FIELD_LENGTH];
    strncpy(newString, yytext, MAX_FIELD_LENGTH);

    if (line_count == 0) { // Jeśli to pierwsza linia, traktujemy ją jako nagłówki
        if (column_count == 0) {
           initStringArray(&headers);
        }
        fillEmptySapce(&headers); // Uzupełnianie braków w nagłówkach
        addString(&headers, newString);
    } else { // Jeśli to nie pierwsza linia, przetwarzamy dane
        if (column_count == 0) {
           initStringArray(&current_line);
        }
        fillEmptySapce(&current_line); // Uzupełnianie braków w danych
        addString(&current_line, newString);
    }
}

{SEPARATOR} {// Obsługa separatora pól
    column_count++; // Przechodzimy do następnej kolumny
}

{ENDLINE} {// Obsługa końca linii
    if (line_count == 0) { // Jeśli to pierwsza linia, inicjalizujemy nagłówki
        column_amount = column_count;

        while (true) {
            printf("Wprowadź filtry (wpisz '-1', aby zakończyć):\n");
            printf("Możliwe wartości:\n");
            printStringArray(&headers);
            printf("\n");

            if (!getFilter()) {
                break; // Zakończenie pobierania filtrów
            }
            printActiveFilters();
        }

        // Inicjalizacja kolumn do wyświetlania
        // Początkowo wszystkie kolumny są wyświetlane
        for (int i = 0; i < column_amount; i++) {
            displayed_columns[i] = i;
        }
        displayed_count = column_amount;

        while (true) {
            printf("Podaj kolumny do ignorowania (wpisz '-1', aby zakończyć):\n");
            printf("Możliwe wartości:\n");
            for (int i = 0; i < displayed_count; i++) {
                int displayedID = displayed_columns[i];
                printf("%d: %s\n", displayedID, headers.strings[displayedID]);
            }
            int column_I = selectIgnoredColumns();
            if (column_I < 0) {
                break; // Zakończenie wybierania ignorowanych kolumn
            }
            IgnoreColumn(column_I);
        }
    } else {
        // Sprawdzanie zgodności linii z filtrami
        if (checkLine()) {
            printCurrentLine();
        }
    }

    line_count++;
    clean(); // Czyszczenie danych bieżącej linii
}
%%

// Funkcja główna
int main(int argc, char **argv) {
    FILE *file;

    // Sprawdzanie, czy przekazano argument z nazwą pliku
    if (argc < 2) {
        char filename[MAX_FIELD_LENGTH];
        printf("Brak nazwy pliku. Proszę podać nazwę pliku CSV: ");
        scanf("%s", filename);
        file = fopen(filename, "r");
        if (!file) {
            perror("Nie udało się otworzyć pliku");
            return 1;
        }
    } else {
        file = fopen(argv[1], "r");
        if (!file) {
            perror("Nie udało się otworzyć pliku");
            return 1;
        }
    }

    yyin = file; // Przypisanie pliku do lexera
    yylex();     // Rozpoczęcie analizy

    printf("\nDopasowano: %d\n", match_count);
    // Wyświetl indeksy wszystkich dopasowanych lini
    for (int i = 0; i < match_count - 1; i++) {
        printf("%d, ", match_lines[i]);
    }
    if (match_count > 0) {
        printf("%d\n", match_lines[match_count - 1]); // Ostatnia linia bez przecinka
    }

    fclose(file); // Zamknięcie pliku
    // Zwalnianie pamięci
    freeStringArray(&headers);
    freeStringArray(&current_line);
    return 0;
}
