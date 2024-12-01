// Advent of Code 2024 - Day 1: Historian Hysteria, part 2
// Mic, 2024

static void main(String[] args) {
    if (!args.length) {
        println "Error: no input file specified"
        return
    }

    def input = new File(args[0]).readLines()
    def lists = [[], []]
    input.each {
        def values = it.split().collect { it.toInteger() }
        lists[0] += values[0]
        lists[1] += values[1]
    }

    print("Similarity score: " + lists[0].collect { value -> value*lists[1].count(value) }.sum())
}