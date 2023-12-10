/*
 * Advent of Code 2023 - Day 7: Camel Cards, part 2
 * Mic, 2023
 *
 * Requires Go 1.9 or later to build.
 */

package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
    "sort"
    "strconv"
    "strings"
)

const CARD_LABELS = "J23456789TQKA"

type Card = rune

type CardWithCount struct {
    card Card
    count int
}

func cardValue(card Card) int {
    return strings.IndexRune(CARD_LABELS, card)
}

func groupByValue(cards []Card) map[Card]int {
    grouped := map[Card]int{}
    for _,c := range cards {
        grouped[c] += 1
    }
    return grouped
}

func strength(cards []Card) int {
    grouped := groupByValue(cards)
    jokers := grouped['J']
    if jokers > 0 && jokers < 5 {
        delete(grouped, 'J')
    } else {
        jokers = 0
    }
    sorted := []CardWithCount{}
    for k,v := range grouped {
        sorted = append(sorted, CardWithCount{k, v})
    }
    sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].count > sorted[j].count
	})
    sorted[0].count += jokers
    result := sorted[0].count * 2
    if (sorted[0].count == 3 || sorted[0].count == 2) && sorted[1].count == 2 {
        result += 1   // Full house or Two pair
    }
    return result
}

type Player struct {
    cards []Card
    bet int
}

// playerString is e.g. "J25T2 123"
func NewPlayer(playerString string) *Player {
    p := &Player{}
    fields := strings.Fields(playerString)
    p.cards = []Card(fields[0])
    bet, err := strconv.Atoi(fields[1])
    if err != nil {
        log.Fatal(err)
    }
    p.bet = bet
    return p
}

func (player *Player) HasBetterHandThan(other *Player) bool {
    ownStrength := strength(player.cards)
    otherStrength := strength(other.cards)
    if ownStrength == otherStrength {
        for i,c := range player.cards {
            cv1 := cardValue(c)
            cv2 := cardValue(other.cards[i])
            if cv1 != cv2 {
                return cv1 > cv2
            }
        }
        return false
    } else {
        return ownStrength > otherStrength
    }
}

func main() {
    if len(os.Args) < 2 {
        log.Fatal("Usage: advent7-2 input.txt")
    }

    file, err := os.Open(os.Args[1])
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    players := []*Player{}
    for scanner.Scan() {
        players = append(players, NewPlayer(scanner.Text()))
    }

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }

    sort.Slice(players, func(i, j int) bool {
		return players[j].HasBetterHandThan(players[i])
	})
    winnings := 0
    for i,p := range players {
        winnings += p.bet * (i+1)
    }
    fmt.Printf("The total winnings are: %d\n", winnings)
}