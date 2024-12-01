// Advent of Code 2024 - Day 1: Historian Hysteria, part 1
// Mic, 2024

static void main(String[] args) {
  if (!args.length) {
    println "Error: no input file specified"
    return
  }

  def lists = new File(args[0]).readLines().collect { it.split().collect { it.toInteger() } }.transpose().collect { it.sort() }
  print("Total distance between lists: " + lists[0].withIndex().collect { value, index -> Math.abs(lists[1][index] - value) }.sum())
}