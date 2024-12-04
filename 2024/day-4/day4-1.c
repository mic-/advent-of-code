// Advent of Code 2024 - Day 4: Ceres Search, part 1
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

int spells_xmas(const Puzzle *puzzle, int row, int column, int dy, int dx) {
    static const char look_for[] = "MAS";
    for (int i = 0; i < 3; ++i) {
        column += dx;
        row += dy;
        if (get(puzzle, row, column) != look_for[i]) return 0;
    }
    return 1;
}

int count_xmas(const Puzzle *puzzle, int row, int column) {
    return spells_xmas(puzzle, row, column, 1, 0) + spells_xmas(puzzle, row, column, -1, 0) +
        spells_xmas(puzzle, row, column, 0, 1) + spells_xmas(puzzle, row, column, 0, -1) +
        spells_xmas(puzzle, row, column, 1, 1) + spells_xmas(puzzle, row, column, 1, -1) +
        spells_xmas(puzzle, row, column, -1, 1) + spells_xmas(puzzle, row, column, -1, -1);
}

int main(int argc, char **argv)
{
    if (argc < 2) {
        puts("Usage: day4-1 <input>\n");
        exit(EXIT_FAILURE);
    }

    Puzzle puzzle = init_puzzle(argv[1]);
    int xmas = 0;
    for (int i = 0; i < puzzle.rows; i++) {
        for (int j = 0; j < puzzle.columns; j++) {
            if (get(&puzzle, i, j) == 'X') {
                xmas += count_xmas(&puzzle, i, j);
            }
        }
    }
    free_puzzle(&puzzle);
    printf("XMAS appears %d times\n", xmas);
    return 0;
}
