/**
 * Advent of Code 2023 - Day 11: Cosmic Expansion, part 1
 * Mic, 2023
 */

class Galaxy {
  Galaxy(x, y) { this.x = x; this.y = y }
  def distanceTo(Galaxy other) { Math.abs(x - other.x) + Math.abs(y - other.y) }
  int x, y
}

class Space {
  Space(List<String> image) {
    this.image = image.collect { it.toCharArray() }
  }

  private def expandRow(int index) {
    String expanded = ""
    image[index].eachWithIndex{ c, x ->
      expanded += c
      def allEmpty = (0..<image.size()).inject(true) { t, y -> t && image[y][x] == (char)'.' }
      if (allEmpty) expanded += c
    }
    return expanded.toCharArray()
  }

  def expand() {
    ArrayList<char[]> expanded = []
    image.eachWithIndex{ line, i ->
      def expandedRow = expandRow(i)
      expanded += expandedRow
      if (line.every { it == '.' }) {
        expanded += expandedRow
      }
    }
    image = expanded
    return this
  }

  def findGalaxies() {
    return image.withIndex().collect { line, y ->
      line.findIndexValues { it == '#' }
              .collect { x -> new Galaxy(x, y) }
    }.findAll().collectMany { it }
  }

  List<char[]> image
}

static void main(String[] args) {
  if (!args.length) {
    println "Error: no input file specified"
    return
  }
  def space = new Space(new File(args[0]).readLines())
  def galaxies = space.expand().findGalaxies()
  print "Sum of distances: " + galaxies.withIndex().collect { galaxy, index ->
    (index+1..<galaxies.size()).collect{ galaxies[it] }.sum { galaxy.distanceTo(it) }
  }.findAll().sum()
}