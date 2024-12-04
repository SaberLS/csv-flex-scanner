// string_array.c

#include "string_array.h"
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>

// Inicjalizacja struktury
void initStringArray(StringArray *arr) {
    arr->strings = (char **)malloc(10 * sizeof(char *));  // Alokacja początkowej pamięci
    arr->size = 0;
    arr->capacity = 10;
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
            exit(EXIT_FAILURE);
        }
        arr->capacity = new_capacity;
    }

    // Alokowanie pamięci i kopiowanie stringa
    arr->strings[arr->size] = strdup(str);
    if (!arr->strings[arr->size]) {
        perror("Failed to allocate memory for string");
        exit(EXIT_FAILURE);
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
    for (size_t i = 0; i < arr->size; i++) {
        printf("%ld: %s\n", i, arr->strings[i]);
    }
}

// Wstaw string w określonym indeksie
void insertString(StringArray *arr, size_t index, const char *str) {
    // Sprawdzenie, czy indeks mieści się w dozwolonym zakresie
    if (index > arr->size) {
        // Jeśli indeks przekracza rozmiar, ustawiamy indeks na rozmiar (dodanie na końcu)
        index = arr->size;
    }

    // Sprawdzamy, czy tablica ma wystarczającą pojemność
    if (arr->size >= arr->capacity) {
        arr->capacity *= 2;
        arr->strings = (char **)realloc(arr->strings, arr->capacity * sizeof(char *));
    }

    // Przesuwamy wszystkie elementy w prawo, aby zrobić miejsce
    for (size_t i = arr->size; i > index; i--) {
        arr->strings[i] = arr->strings[i - 1];
    }

    // Jeśli indeks przekroczył aktualny rozmiar, wstawiamy pusty string w brakujących miejscach
    for (size_t i = arr->size; i < index; i++) {
        arr->strings[i] = (char *)malloc(1);  // Alokujemy miejsce na pusty string
        arr->strings[i][0] = '\0';           // Ustawiamy pusty string
    }

    // Wstawiamy nowy string
    arr->strings[index] = (char *)malloc(strlen(str) + 1);
    strcpy(arr->strings[index], str);

    // Zwiększamy rozmiar
    arr->size++;
}
