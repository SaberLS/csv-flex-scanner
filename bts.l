%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "string_array.h"

#define MAX_COLUMNS 100
#define MAX_FIELD_LENGTH 128

int column_count = 0;
int column_amount = 0;
int line_count = 0;

int displayed_columns[MAX_COLUMNS];
int displayed_count = 0;

int match_count = 0;
int match_lines[MAX_COLUMNS];

StringArray headers;
StringArray current_line;

int ignored_columns[MAX_COLUMNS];
int ignored_count = 0;
// Struktura przechowująca filtr
struct filter {
    int column_I;                // Indeks kolumny
    char value[MAX_FIELD_LENGTH];
} filters[MAX_COLUMNS];

int filter_count = 0;
// Dodanie filtra
void addFilter(int column_I, char *value) {
    filters[filter_count].column_I = column_I;
    strcpy(filters[filter_count].value, value);
    filter_count++;
}

bool getFilter() {
    int column_I = -1;
    char value[MAX_FIELD_LENGTH];

    printf("<numer kolumny>: ");
    scanf("%d", &column_I);
    if (column_I < 0) {
        return false;
    }

    printf("<wartość>: ");
    scanf("%s", value);

    addFilter(column_I, value);
    return true;
}

void printActiveFilters() {
    printf("\n--------------------------\nAktywne filtry:\n");
    for (int i = 0; i < filter_count; i++) {
        printf("%s: %s\n", headers.strings[filters[i].column_I], filters[i].value);
    }
    printf("--------------------------\n");
}

void printHeaders() {
    for (int i = 0; i < column_amount; i++) {
        printf("%d: %s\n", i, headers.strings[i]);
    }
    printf("\n");
}

    void clean() {
    column_count = 0;

    // Wyczyszczenie bieżącej linii
    freeStringArray(&current_line);
}


void printCurrentLine() {
    match_lines[match_count] = line_count + 1; // +1, bo liczy linie od 0 bez nagłówka
    match_count++;

    printf("----------------------------\n");
    printf("Linia nr: %d\n", line_count + 1);
    for (int i = 0; i < displayed_count; i++) {
        int displayedID = displayed_columns[i];
        printf("%s: %s\n", headers.strings[displayedID], current_line.strings[displayedID]);
    }
    printf("----------------------------\n");
}

// Funkcja sprawdzająca zgodność wiersza z filtrami
bool checkLine() {
    for (int i = 0; i < filter_count; i++) {
        int column_I = filters[i].column_I;

        // Sprawdzanie, czy indeks filtra mieści się w zakresie kolumn
        if (column_I < column_amount) {
            // Jeśli wiersz nie spełnia kryteriów filtra, zwróć false
            if (strcmp(current_line.strings[column_I], filters[i].value) != 0) {
                return false;
            }
        }
    }
    return true;
}

// Uzupełnij puste miejsca
void fillEmptySapce(StringArray *arr) {
    while(column_count > (int)arr->size){
        addString(arr, " ");
    }
}

%}

%option noyywrap
FIELD [^;\n]+
SEPARATOR ;
ENDLINE \n

%%
{FIELD} {
    char newString[strlen(yytext)];
    strcpy(newString, yytext);

    if (line_count == 0) {
        if(column_count == 0){
           initStringArray(&headers);
        }

        // Uzupełnij puste miejsca
        fillEmptySapce(&headers);

        addString(&headers, newString);
    } else {
        if(column_count == 0){
           initStringArray(&current_line);
        }

        // Uzupełnij puste miejsca
        fillEmptySapce(&current_line);

        addString(&current_line, newString);
    }
}
{SEPARATOR} {
    column_count++; // Separator - przechodzimy do następnej kolumny
}
{ENDLINE} {
    if (line_count == 0) {
        column_amount = column_count;

        while (true) {
            // Pobieranie filtrów od użytkownika
            printf("Wprowadź filtry w postaci: <numer kolumny> <wartość> (wpisz '-1', aby zakończyć):\n");
            printf("Możliwe wartości:\n");
            printStringArray(&headers);
            printf("\n");

            if(!getFilter()){
                break;
            };

            printActiveFilters();
        }

        while(true){
            printf("Podaj numery kolumn które mają zostać zignorowane (wpisz '-1', aby zakończyć):\n");
            printf("Możliwe wartości:\n");
            printStringArray(&headers);
            int column_I = -1;

            printf("<numer kolumny>: ");
            scanf("%d", &column_I);
            if (column_I < 0) {
                break;
            }

            ignored_columns[ignored_count] = column_I;
            ignored_count++;
        }

        for(int i = 0; i < column_amount; i++){
            bool mark = true;
            for(int j = 0; j < ignored_count; j++){
                if(i == ignored_columns[j]){
                    mark = false;
                    break;
                }
            }
            if(mark){
                displayed_columns[displayed_count] = i;
                displayed_count++;
            }
        }
    } else {
        // Sprawdzenie, czy wiersz spełnia kryteria filtrów
        if (checkLine()) {
            printCurrentLine();
        }
    }

    line_count++;
    clean();
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
        file = fopen(argv[1], "r");
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
