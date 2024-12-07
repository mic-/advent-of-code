/*
 * Advent of Code 2024 - Day 6: Guard Gallivant, part 2
 * Mic, 2024
 */

package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
    "strings"
    "sync"
)

type Puzzle struct {
    data []string
    width int
    height int
}

type Position struct {
    x int
    y int
}

type Guard struct {
    pos Position
    direction int
}

var Directions = [...]Position {
    Position{-1, 0}, // left
    Position{0, -1}, // up
    Position{1,  0}, // right
    Position{0,  1}, // down
}
const DIRECTION_RUNES = "<^>v"

func NewPuzzle() *Puzzle {
    p := &Puzzle{}
    p.width = 0
    p.height = 0
    return p
}

func (puzzle *Puzzle) AddRow(puzzleRowString string) {
    puzzle.data = append(puzzle.data, puzzleRowString)
    puzzle.height += 1
    puzzle.width = len(puzzle.data[0])
}

func (puzzle *Puzzle) WithinBounds(pos Position) bool {
    return pos.x >= 0 && pos.x < puzzle.width && pos.y >= 0 && pos.y < puzzle.height
}

func (puzzle *Puzzle) AtObstacle(pos Position) bool {
    return puzzle.WithinBounds(pos) && puzzle.data[pos.y][pos.x] == '#'
}

func (puzzle *Puzzle) FindGuard() *Guard {
    guard := &Guard{}
    for y := 0; y < puzzle.height; y++ {
        for x, char := range puzzle.data[y] {
            if char != '.' && char != '#' {
                guard.pos = Position{x, y}
                guard.direction = strings.IndexRune(DIRECTION_RUNES, char)
            }
        }
    }
    return guard
}

func (guard *Guard) Move(puzzle *Puzzle, extraObstacle Position) bool {
    direction := Directions[guard.direction]
    nextPos := guard.pos
    nextPos.x += direction.x
    nextPos.y += direction.y
    if (puzzle.AtObstacle(nextPos) || (nextPos.x == extraObstacle.x && nextPos.y == extraObstacle.y)) {
        return false
    }
    guard.pos = nextPos
    return true
}

func (guard *Guard) Turn90DegreesRight() {
    guard.direction = (guard.direction + 1) & 3
}

func (guard Guard) MoveUntilStuckOrOutOfBounds(puzzle *Puzzle, extraObstacle Position, ch chan int) {
    visited := map[Position]int{}
    stuck := 0
    for stuck == 0 {
        if wasFacing, ok := visited[guard.pos]; ok {
            if (wasFacing == guard.direction) {
                stuck = 1
            }
        } else {
            visited[guard.pos] = guard.direction
        }

        if (guard.Move(puzzle, extraObstacle)) {
            if (!puzzle.WithinBounds(guard.pos)) { break }
        } else {
            guard.Turn90DegreesRight()
        }
    }
    ch <- stuck
}

func main() {
    if len(os.Args) < 2 {
        log.Fatal("Usage: advent6-2 input.txt")
    }

    file, err := os.Open(os.Args[1])
    if err != nil { log.Fatal(err) }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    puzzle := NewPuzzle()
    for scanner.Scan() {
        puzzle.AddRow(scanner.Text())
    }
    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }

    guard := puzzle.FindGuard()
    results := make(chan int)
    var wg sync.WaitGroup
    for y := 0; y < puzzle.height; y++ {
        for x := 0; x < puzzle.width; x++  {
            wg.Add(1)
            go func(extraObstacle Position) {
                defer wg.Done()
                (*guard).MoveUntilStuckOrOutOfBounds(puzzle, extraObstacle, results)
            }(Position{x,y})
        }
    }
    go func() {
        wg.Wait()
        close(results)
    }()

    timesStuck := 0
    for stuck := range results {
        timesStuck += stuck
    }

    fmt.Printf("Obstacle positions that get the guard stuck: %d\n", timesStuck)
}