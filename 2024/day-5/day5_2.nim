# Advent of Code 2024 - Day 5: Print Queue, part 2
# Mic, 2024

import std/os
import std/sequtils
import std/strutils

type
  Rule = ref object of RootObj
    order: seq[int]

type
  Update = ref object of RootObj
    pages: seq[int]

proc newRule(ruleString: string): Rule =
  let s = ruleString.split("|")
  Rule(order: map(s, proc(x: string): int = parseInt(x)))

proc newUpdate(updateString: string): Update =
  let s = updateString.split(",")
  Update(pages: map(s, proc(x: string): int = parseInt(x)))

proc getMiddlePageIfInCorrectOrder(self: Update, rules: seq[Rule]): int =
  var pages = self.pages
  var index1 = 0
  var fixed = false
  while index1 < pages.len:
    var inc = 1
    for ir, rule in rules:
      let page1 = pages[index1]
      if (page1 == rule.order[0] or page1 == rule.order[1]):
        let page1Order = rule.order.find(page1)
        for index2 in 0..pages.len-1:
          let page2 = pages[index2]
          let page2Order = rule.order.find(page2)
          if index1 != index2 and page2Order != -1:
            if (page1Order < page2Order and index1 > index2) or (page1Order > page2Order and index1 < index2):
              pages[index2] = page1
              pages[index1] = page2
              index1 = min(index1, index2)
              inc = 0
              fixed = true
    index1 += inc
  if fixed: pages[pages.len div 2] else: 0


let filename = commandLineParams()[0]
var rules = newSeq[Rule]()
var updates = newSeq[Update]()
for line in lines filename:
  if "|" in line:
    rules.add(newRule(line))
  elif "," in line:
    updates.add(newUpdate(line))

var sumOfMiddlePages = 0
for update in updates:
    sumOfMiddlePages += update.getMiddlePageIfInCorrectOrder(rules)

echo "The sum of the middle pages: ", sumOfMiddlePages
