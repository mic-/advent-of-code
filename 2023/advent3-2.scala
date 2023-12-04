/*
 * Advents of Code 2023 - Day 3: Gear Ratios, part 2
 * Mic, 2023
 */

import scala.io.Source
import scala.util.matching.Regex

class Schematic(filename: String) {
    private val numberPattern: Regex = "([0-9]+)".r
    private val lines = Source.fromFile(filename).getLines.toList

    lazy val partNumbers = {
        lines.map(line => numberPattern.findAllMatchIn(line).toList)
    }

    lazy val gears = {
        lines.zipWithIndex.flatMap { case (line, row) =>
            line.zipWithIndex.filter(_._1 == '*').map(_._2).map(new Gear(_, row))
        }
    }
}

class Gear(val column: Int, val row: Int) {
    def mod(x: Int, y: Int) = {
        (x % y) + (if (x < 0) y else 0)
    }

    def getAdjacentPartNumbers(schematic: Schematic): List[Int] = {
        val partNumbers = schematic.partNumbers
        val numbersAbove = partNumbers(mod(row-1, partNumbers.length)).filter(it => (it.start <= column && it.end >= column) || (it.start == column+1) || (it.end == column))
        val numbersBelow = partNumbers(mod(row+1, partNumbers.length)).filter(it => (it.start <= column && it.end >= column)  || (it.start == column+1) || (it.end == column))
        val numbersOnSameRow = partNumbers(row).filter(it => it.end == column || it.start == column+1)
        (numbersAbove ++ numbersOnSameRow ++ numbersBelow).map(_.matched.toInt)
    }
}

object Advent {
    def main(args: Array[String]): Unit = {
        if (args.isEmpty) {
            println("Usage: scala advent3-2.scala <input file>")
            return ()
        }
        val schematic = new Schematic(args(0))
        val gearRatios = schematic.gears
            .map(_.getAdjacentPartNumbers(schematic))
            .filter(_.length == 2)
            .map(it => it(0) * it(1))
        println("The sum of all gear ratios is: " + gearRatios.sum)
    }
}

Advent.main(args)