# Advents of Code 2023 - Day 2: Cube Conundrum, part 2
# Mic, 2023

import std/nre
import std/os
import std/sequtils
import std/strutils
import std/sugar

type
  CubeSet = object
    red: Natural
    green: Natural
    blue: Natural

proc power(self: CubeSet): Natural =
  self.red * self.green * self.blue

proc getNumberOfCubes(cubeSetString: string, color: string): Natural =
  let pattern = "([0-9]+) " & color
  try: parseInt(cubeSetString.find(re(pattern)).get.captures[0]) except: 0

type
  Game = ref object of RootObj
    cubeSets: seq[CubeSet]

proc newGame(gameString: string): Game =
  Game(cubeSets: gameString
    .split(":")[1]
    .split(";")
    .map(it => CubeSet(
      red: getNumberOfCubes(it, "red"),
      green: getNumberOfCubes(it, "green"),
      blue: getNumberOfCubes(it, "blue")
    ))
  )

proc getMaxCubeSet(self: Game): CubeSet =
  CubeSet(
    red: self.cubeSets.foldl(if b.red>a: b.red else: a, -1),
    green: self.cubeSets.foldl(if b.green>a: b.green else: a, -1),
    blue: self.cubeSets.foldl(if b.blue>a: b.blue else: a, -1),
  )


let filename = commandLineParams()[0]
var sumOfPowers = 0
for line in lines filename:
    sumOfPowers += newGame(line).getMaxCubeSet.power
echo "The sum of powers: ", sumOfPowers