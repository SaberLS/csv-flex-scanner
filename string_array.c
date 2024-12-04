// string_array.c

#include "string_array.h"
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>

// Inicjalizacja struktury
void initStringArray(StringArray *arr) {
    arr->strings = NULL;  // Na początku brak elementów
    arr->size = 0;
    arr->capacity = 0;
}

// Zwalnianie pamięci zajmowanej przez tablicę
void freeStringArray(StringArray *arr) {
    for (size_t i = 0; i < arr->size; ++i) {
        free(arr->strings[i]);  // Zwalnianie pamięci zajmowanej przez każdy string
    }
    free(arr->strings);  // Zwalnianie pamięci tablicy wskaźników
    arr->strings = NULL;
    arr->size = 0;
    arr->capacity = 0;
}

// Dodawanie stringa do tablicy
void addString(StringArray *arr, const char *str) {
    // Sprawdzanie, czy potrzebujemy zwiększyć pojemność
    if (arr->size == arr->capacity) {
        size_t new_capacity = (arr->capacity == 0) ? 1 : arr->capacity * 2;
        arr->strings = realloc(arr->strings, new_capacity * sizeof(char*));
        if (!arr->strings) {
            perror("Failed to reallocate memory");
            exit(1);
        }
        arr->capacity = new_capacity;
    }

    // Alokowanie pamięci i kopiowanie stringa
    arr->strings[arr->size] = strdup(str);
    if (!arr->strings[arr->size]) {
        perror("Failed to allocate memory for string");
        exit(1);
    }
    arr->size++;
}

// Usuwanie stringa z tablicy po indeksie
void removeString(StringArray *arr, size_t index) {
    if (index >= arr->size) {
        printf("Index out of bounds\n");
        return;
    }

    free(arr->strings[index]);  // Zwalnianie pamięci zajmowanej przez string

    // Przesuwanie elementów, aby usunąć lukę
    for (size_t i = index; i < arr->size - 1; ++i) {
        arr->strings[i] = arr->strings[i + 1];
    }

    arr->size--;
}

// Wyświetlanie zawartości tablicy
void printStringArray(const StringArray *arr) {
    for (size_t i = 0; i < arr->size; ++i) {
        printf("%s\n", arr->strings[i]);
    }
}
