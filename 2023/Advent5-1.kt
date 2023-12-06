/*
 * Advent of Code 2023 - Day 5: If You Give A Seed A Fertilizer, part 1
 * /Mic, 2023
 */

import java.io.File
import kotlin.system.exitProcess

open class Entity(val name: String = "", val id: Long = 0)

class Seed(id: Long) : Entity("seed", id)

class Mapping(
    val destination: String = "",
    val sourceRanges: MutableList<LongRange> = mutableListOf(),
    val destinationRanges: MutableList<LongRange> = mutableListOf()
) {
    fun getDestinationId(sourceId: Long): Long {
        val rangeIndex = sourceRanges.indexOfFirst { it.contains(sourceId) }
        return if (rangeIndex in sourceRanges.indices) {
            destinationRanges[rangeIndex].first + sourceId - sourceRanges[rangeIndex].first
        } else {
            sourceId
        }
    }
}

fun Map<String, Mapping>.get(what: String, from: Entity): Long {
    val mapping = this[from.name] ?: throw IllegalArgumentException()
    val destinationId = mapping.getDestinationId(from.id)
    return if (mapping.destination == what) {
        destinationId
    } else {
        get(what, from = Entity(mapping.destination, destinationId))
    }
}

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        println("Error: no input file specified")
        exitProcess(0)
    }

    val seeds = mutableListOf<Seed>()
    val mappings = mutableMapOf<String, Mapping>()
    var currentMapping = Mapping()

    File(args.first()).forEachLine { line ->
        when {
            line.startsWith("seeds:") -> {
                line.split(":").last().split(" ").filter { it.isNotEmpty() }.forEach {
                    seeds.add(Seed(it.toLong()))
                }
            }

            line.endsWith("map:") -> {
                val (source, destination) = line.split(" ").first().split("-to-")
                currentMapping = Mapping(destination)
                mappings[source] = currentMapping
            }

            else -> {
                val numbers = line.split(" ")
                if (numbers.size == 3) {
                    val (destStart, sourceStart, length) = numbers.map { it.toLong() }
                    currentMapping.destinationRanges.add(LongRange(destStart, destStart+length-1))
                    currentMapping.sourceRanges.add(LongRange(sourceStart, sourceStart+length-1))
                }
            }
        }
    }
    val lowestLocation = seeds.minOfOrNull { mappings.get("location", from = it) }
    println("Lowest location is $lowestLocation")
}