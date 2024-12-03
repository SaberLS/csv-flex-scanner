%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_COLUMNS 50
#define MAX_FIELD_LENGTH 128
#define MAX_HEADER_LENGTH 256

int column_count = 0;
int column_amount = 0;
int line_count = 0;

int match_count = 0;
int match_lines[MAX_COLUMNS];
char headers[MAX_COLUMNS][MAX_FIELD_LENGTH];
char current_line[MAX_COLUMNS][MAX_FIELD_LENGTH];

// Struktura przechowująca filtr
struct filter {
    int column_I;                // Indeks kolumny - poprawione z tablicy wskaźników na int
    char value[MAX_FIELD_LENGTH];
} filters[MAX_COLUMNS];

int filter_count = 0;

void printHeaders() {
    printf("| ");
    for (int i = 0; i < column_amount; i++) {
        printf(" %s |", headers[i]);
    }
    printf("\n");
}

void printActiveFilters() {
    printf("\n--------------------------\nAktywne filtry:\n");
    for (int i = 0; i < filter_count; i++) {
        printf("%s: %s\n", headers[filters[i].column_I], filters[i].value);
    }
    printf("--------------------------\n");
}

// Funkcja sprawdzająca zgodność wiersza z filtrami
bool checkLine() {
    for (int i = 0; i < filter_count; i++) {
        int column_I = filters[i].column_I;

        // Sprawdzanie, czy indeks filtra mieści się w zakresie kolumn
        if (column_I < column_amount) {
            // Jeśli wiersz nie spełnia kryteriów filtra, zwróć false
            if (strcmp(current_line[column_I], filters[i].value) != 0) {
                return false;
            }
        }
    }
    return true;
}
%}

%option noyywrap
FIELD [^;\n]+
SEPARATOR ;
ENDLINE \n

%%
{FIELD} {
    if (line_count == 0) {
        strcpy(headers[column_count], yytext);
    } else {
        strncpy(current_line[column_count], yytext, MAX_FIELD_LENGTH);
    }
}
{SEPARATOR} {
    column_count++; // Separator - przechodzimy do następnej kolumny
}
{ENDLINE} {
    if (line_count == 0) {
        column_amount = column_count;

        // Pobieranie filtrów od użytkownika
        printf("Wprowadź filtry w postaci: <numer kolumny> <wartość> (wpisz '-1', aby zakończyć):\n");
        while (1) {
            printf("Możliwe wartości:\n");
            for (int i = 0; i < column_amount; i++) {
                printf("%d: %s\n", i, headers[i]);
            }
            printf("\n");

            int column_I = -1;
            char value[MAX_FIELD_LENGTH];

            printf("Numer kolumny: ");
            scanf("%d", &column_I);
            if (column_I < 0) {
                break;
            }

            printf("Wartość: ");
            scanf("%s", value);

            // Dodanie filtra
            filters[filter_count].column_I = column_I;
            strcpy(filters[filter_count].value, value);
            filter_count++;

            printActiveFilters();

        }
    } else {
        // Sprawdzenie, czy wiersz spełnia kryteria filtrów
        if (checkLine()) {
            match_lines[match_count] = line_count + 1; // +1, bo liczy linie od 0 bez nagłówka
            match_count++;

            printf("----------------------------\n");
            printf("Linia nr: %d\n", line_count + 1);
            for (int i = 0; i < column_amount; i++) {
                printf("%s: %s\n", headers[i], current_line[i]);
            }
            printf("----------------------------\n");
        }
    }
    line_count++;
    column_count = 0;

    // Wyczyszczenie bieżącej linii
    for (int i = 0; i < column_amount; i++) {
        strcpy(current_line[i], "");
    }
}
%%

int main(int argc, char **argv) {
    FILE *file;

    // Jeśli brak argumentu, prosimy użytkownika o nazwę pliku
    if (argc < 2) {
        char filename[MAX_FIELD_LENGTH];

        // Prośba o podanie nazwy pliku
        printf("Brak nazwy pliku. Proszę podać nazwę pliku CSV: ");
        scanf("%s", filename);

        // Próba otwarcia pliku podanego przez użytkownika
        file = fopen(filename, "r");
        if (!file) {
            perror("Nie udało się otworzyć pliku");
            return 1;
        }
    } else {
        // Jeśli argument jest przekazany, otwieramy plik
        file = fopen(argv[1], "r");501501502
        if (!file) {
            perror("Nie udało się otworzyć pliku");
            return 1;
        }
    }

    yyin = file;
    yylex();
    printf("\nDopasowano: %d\n", match_count);
    for (int i = 0; i < match_count - 1; i++) {
        printf("%d, ", match_lines[i]);
    }
    if (match_count > 0) {
        printf("%d\n", match_lines[match_count - 1]); // Unikamy przecinka na końcu
    }
    fclose(file);
    return 0;
}
