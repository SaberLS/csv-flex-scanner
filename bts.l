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
    int column_I[MAX_FIELD_LENGTH];
    char value[MAX_FIELD_LENGTH];
} filters[MAX_COLUMNS];

int filter_count = 0;

void printHeaders() {
    printf("| ");
    for(int i = 0; i < column_amount; i++){
        printf("%d: %s |", i, headers[i]);
    }
}

// true if whole line meets requirements of filters false if any current_line elment doesn't
bool checkLine() {
    for(int i = 0; i < filter_count; i++){
        int column_I = *filters[i].column_I;

        // check if filter.column_I is in current_line array bounds
        if(column_I <= column_amount){
            // if current line does not fill the filter requirements return false
            if(strcmp(current_line[column_I], filters[i].value) != 0)
                return false;
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
    if(line_count == 0){
        strcpy(headers[column_count],yytext);
    } else {
        strncpy(current_line[column_count],yytext, MAX_FIELD_LENGTH);
    }
}
{SEPARATOR} {
    // Separator - przechodzimy do następnego pola
    column_count++;
}

{ENDLINE} {
    // Koniec linii - przetwarzamy i wypisujemy rekord
    if(line_count == 0){
        column_amount = column_count;
            // Pobieramy filtry
        printf("Wprowadź filtry w postaci: <nazwa kolumny> <wartość> (wpisz 'koniec' aby zakończyć):\n");
        while (1) {
            printf("Możliwe wartości: \n");
            printHeaders();
            printf("\n");

           int column_I = -1;
           char value[MAX_FIELD_LENGTH];

            printf("Numer kolumny: ");
            scanf("%d", &column_I);
            if(column_I < 0){
                break;
            }

            printf("Wartość: ");
            scanf("%s", value);

            // Dodajemy filtr
            *filters[filter_count].column_I = column_I;
            strcpy(filters[filter_count].value, value);
            filter_count++;

            printf("--------------------------\nActive Filters: \n");
            for(int i = 0; i < filter_count; i++){
                printf("%d: %s \n", *filters[i].column_I, filters[i].value);
            }
            printf("--------------------------\n");

    } } else {
        if(checkLine()){
            match_lines[match_count] = line_count + 1; // + 1 bo liczy linie od 0 bez nagłówka
            match_count++;
            printf("----------------------------\n");
            printf("linia nr.: %d\n", line_count + 1);
            for(int i = 0; i < column_amount; i++){
                printf("%s: %s\n", headers[i], current_line[i]);
            }
            printf("----------------------------");
        }
    }
    line_count++;
    column_count = 0;

    // overrite current line elements with defaults
    for(int i = 0; i < column_amount; i++){
        strcpy(current_line[i], "");
    }
}

%%

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <csv_file>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("File opening failed");
        return 1;
    }

    printf("Enter phone number to search: ");
    //scanf("%s", target_phone);

    yyin = file;
    yylex();
    printf("\ndopasowano: %d\n", match_count);
        for(int i = 0; i < match_count - 1; i++){
            printf("%d, ", match_lines[i]);
        }
        printf("%d\n", match_lines[match_count - 1]); // żeby nie było , na końcu
    fclose(file);
    return 0;
}
