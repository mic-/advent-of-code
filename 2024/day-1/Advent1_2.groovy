// Advent of Code 2024 - Day 1: Historian Hysteria, part 2
// Mic, 2024

static void main(String[] args) {
    if (!args.length) {
        println "Error: no input file specified"
        return
    }

    def lists = new File(args[0]).readLines().collect { it.split() }.transpose()
    print("Similarity score: " + lists[0].collect { value -> value.toInteger()*lists[1].count(value) }.sum())
}