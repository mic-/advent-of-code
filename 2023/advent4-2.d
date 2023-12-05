/*
 * Advent of Code 2023 - Day 4: Scratchcards, part 2
 * /Mic, 2023
 */
module advent4_2;

import std.algorithm, std.conv, std.range, std.stdio, std.string;
import core.stdc.stdlib;

class Card
{
    this(char[] cardString)
    {
        auto parts = cardString.split("|");
        auto winning = parts[0]
            .split(":")[1]
            .split
            .map!(s => parse!uint(s));
        auto have = parts[1]
            .split
            .map!(s => parse!uint(s));
        winningNumbers = have.filter!(a => winning.canFind(a)).walkLength;
        numberOfCopies = 1;
    }

    void addCopies(uint n) { numberOfCopies += n; }

    @property uint copies() { return numberOfCopies; }

    immutable uint winningNumbers;
    private uint numberOfCopies;
};

void main(string[] args)
{
    if (args.length < 2)
    {
        writeln("Usage: advent4-2 input.txt");
        exit(0);
    }

    auto file = File(args[1]);
    Card[] cards;
    foreach(line; file.byLine())
    {
        cards ~= new Card(line);
    }
    foreach(i, card; cards)
    {
        for (int j = i + 1; j < cards.length && j <= i + card.winningNumbers; j++)
        {
            cards[j].addCopies(card.copies);
        }
    }
    writeln("Total number of scratchcards: ", cards.fold!((a, b) => a + b.copies)(0));
}