// Advent of Code 2023 - Day 16: The Floor Will Be Lava, part 2
// Mic, 2023

#include <ctype.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ROWS 512
#define MAX_COLS 512

enum Direction { UP=1, RIGHT=2, DOWN=4, LEFT=8 };

typedef struct {
    int x, y;
    enum Direction direction;
} Beam;

char *tiles[MAX_ROWS];
char *energized[MAX_ROWS];

int num_rows = 0;
int num_cols = 0;

char* rtrim(char *str) {
    char *end = str + strlen(str) - 1;
    while (end > str && isspace(*end)) end--;
    end[1] = 0;
    return str;
}

void clear_energized() {
    for (int i = 0; i < num_rows; i++) memset(energized[i], 0, num_cols);
}

int count_energized() {
    int count = 0;
    for (int i = 0; i < num_rows; i++)
        for (int j = 0; j < num_cols; j++) count += energized[i][j] ? 1 : 0;
    return count;
}

void turn_90_degrees(Beam *beam) {
    beam->direction = ((beam->direction << 1) | (beam->direction & 8) >> 3) & 0xF;
}

void turn_270_degrees(Beam *beam) {
    beam->direction = ((beam->direction >> 1) | (beam->direction & 1) << 3) & 0xF;
}

void move_beam(Beam *beam) {
    switch (beam->direction) {
        case UP: beam->y--; break;
        case DOWN: beam->y++; break;
        case LEFT: beam->x--; break;
        case RIGHT: beam->x++; break;
        default: break;
    }
}

bool is_beam_active(Beam *beam) {
    if ((beam->x >= 0 && beam->x < num_cols) && (beam->y >= 0 && beam->y < num_rows)) {
        return (energized[beam->y][beam->x] & beam->direction) == 0;
    }
    return false;
}

// Recursively trace the path of a beam and its offshoots until it ends
// up out of bounds, or it is moving across a tile that some beam has
// already moved across in the same direction.
void trace_beam(Beam *beam) {
    bool has_active_beam = true;
    while (has_active_beam) {
        move_beam(beam);
        has_active_beam = is_beam_active(beam);
        if (has_active_beam) {
            energized[beam->y][beam->x] |= beam->direction;
            char tile = tiles[beam->y][beam->x];
            switch (tile) {
                case '/':
                    if (beam->direction & (UP|DOWN)) turn_90_degrees(beam);
                    else turn_270_degrees(beam);
                    break;
                case '\\':
                    if (beam->direction & (UP|DOWN)) turn_270_degrees(beam);
                    else turn_90_degrees(beam);
                    break;
                case '|':
                    if (beam->direction & (LEFT|RIGHT)) {
                        beam->direction = UP;
                        Beam new_beam = { .x = beam->x, .y = beam->y, .direction = DOWN };
                        trace_beam(&new_beam);
                    }
                    break;
                case '-':
                    if (beam->direction & (UP|DOWN)) {
                        beam->direction = LEFT;
                        Beam new_beam = { .x = beam->x, .y = beam->y, .direction = RIGHT };
                        trace_beam(&new_beam);
                    }
                    break;
                default: break;
            }
        }
    }
}

int update_energized_count_for_beam(int *max_energized, const int x, const int y, const enum Direction direction) {
    clear_energized();
    Beam beam = { .x = x, .y = y, .direction = direction };
    trace_beam(&beam);
    int e = count_energized();
    if (e > *max_energized) *max_energized = e;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        puts("Usage: advent16-2 input.txt");
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    char line[MAX_COLS];
    while (fgets(line, sizeof(line), file)) {
        energized[num_rows] = rtrim(strdup(line));
        tiles[num_rows++] = rtrim(strdup(line));
    }
    fclose(file);
    num_cols = strlen(tiles[0]);

    int max_energized = 0;
    for (int y = 0; y < num_rows; y++) {
        update_energized_count_for_beam(&max_energized,       -1, y, RIGHT);
        update_energized_count_for_beam(&max_energized, num_cols, y, LEFT);
    }
    for (int x = 0; x < num_cols; x++) {
        update_energized_count_for_beam(&max_energized, x,       -1, DOWN);
        update_energized_count_for_beam(&max_energized, x, num_rows, UP);
    }

    for (int i = 0; i < num_rows; i++) {
        free(tiles[i]);
        free(energized[i]);
    }

    printf("Maximum number of energized tiles: %d\n", max_energized);

    return 0;
}