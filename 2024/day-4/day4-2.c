// Advent of Code 2024 - Day 4: Ceres Search, part 2
// Mic, 2024

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Puzzle {
    char **data;
    int rows;
    int columns;
} Puzzle;

Puzzle init_puzzle(const char *filename) {
    FILE *fp = fopen(filename, "r");
    if (fp == NULL) {
        printf("Unable to open %s\n", filename);
        exit(EXIT_FAILURE);
    }

    Puzzle puzzle = { .data = calloc(512, sizeof(char*)), .rows = 0, .columns = 0};
    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        puzzle.data[puzzle.rows++] = strdup(line);
        puzzle.columns = strlen(line);
    }
    fclose(fp);
    return puzzle;
}

void free_puzzle(const Puzzle *puzzle) {
    for (int i = 0; i < puzzle->rows; ++i) {
        free(puzzle->data[i]);
    }
    free(puzzle->data);
}

char get(const Puzzle *puzzle, int row, int column)
{
    if (row < 0 || row >= puzzle->rows) return 0;
    if (column < 0 || column >= puzzle->columns) return 0;
    return puzzle->data[row][column];
}

int is_x_mas(char c1, char c2) {
    return (c1 == 'M' && c2 == 'S') || (c1 == 'S' && c2 == 'M') ? 1 : 0;
}

int count_xmas(const Puzzle *puzzle, int row, int column) {
    return is_x_mas(get(puzzle, row-1, column-1), get(puzzle, row+1, column+1)) &
        is_x_mas(get(puzzle, row+1, column-1), get(puzzle, row-1, column+1));
}

int main(int argc, char **argv)
{
    if (argc < 2) {
        puts("Usage: day4-2 <input>\n");
        exit(EXIT_FAILURE);
    }

    Puzzle puzzle = init_puzzle(argv[1]);
    int xmas = 0;
    for (int i = 0; i < puzzle.rows; i++) {
        for (int j = 0; j < puzzle.columns; j++) {
            if (get(&puzzle, i, j) == 'A') {
                xmas += count_xmas(&puzzle, i, j);
            }
        }
    }
    free_puzzle(&puzzle);
    printf("X-MAS appears %d times\n", xmas);
    return 0;
}
