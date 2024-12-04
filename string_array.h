// string_array.h

#ifndef STRING_ARRAY_H
#define STRING_ARRAY_H

#include <stddef.h>

// Definicja struktury przechowującej tablicę stringów
typedef struct {
    char **strings;  // Tablica wskaźników na stringi
    size_t size;     // Liczba przechowywanych stringów
    size_t capacity; // Pojemność tablicy (ilość dostępnych miejsc)
} StringArray;

// Funkcje operujące na strukturze
void initStringArray(StringArray *arr);
void freeStringArray(StringArray *arr);
void addString(StringArray *arr, const char *str);
void removeString(StringArray *arr, size_t index);
void printStringArray(const StringArray *arr);

#endif // STRING_ARRAY_H
