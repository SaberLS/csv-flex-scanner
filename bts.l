%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_COLUMNS 50
#define MAX_FIELD_LENGTH 128
#define MAX_HEADER_LENGTH 256

int column_count = 0;
int column_amount = 0;
int line_count = 0;

char target_phone[] = "501501502";
int match_count = 0;
int match_lines[MAX_COLUMNS];
char headers[MAX_COLUMNS][MAX_FIELD_LENGTH];
char current_line[MAX_COLUMNS][MAX_FIELD_LENGTH];

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
    } else {
        if(strcmp(current_line[5], target_phone) == 0){
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
        printf("%d\n", match_lines[match_count - 1]); //żeby nie było , na końcu
    fclose(file);
    return 0;
}
