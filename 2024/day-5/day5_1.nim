# Advent of Code 2024 - Day 5: Print Queue, part 1
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

proc getRulesForPage(page: int, rules: seq[Rule]): seq[Rule] =
  filter(rules, proc(rule: Rule): bool = page == rule.order[0] or page == rule.order[1])

proc getMiddlePageIfInCorrectOrder(self: Update, rules: seq[Rule]): int =
  for index1, page1 in self.pages:
    let matchingRules = getRulesForPage(page1, rules)
    for rule in matchingRules:
      let page1Order = rule.order.find(page1)
      for index2, page2 in self.pages:
        let page2Order = rule.order.find(page2)
        if index1 != index2 and page2Order != -1:
          if (page1Order < page2Order and index1 > index2) or (page1Order > page2Order and index1 < index2):
            return 0
  self.pages[self.pages.len div 2]


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
