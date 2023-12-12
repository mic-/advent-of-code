#!/usr/bin/python

# Advent of Code 2023 - Day 8: Haunted Wasteland, part 2
# Mic, 2023
#
# Requires Pyhon 3.9 or later.

import math
import re
import sys

class Node:
    def __init__(self, name):
        self.name = name
        self.left = None
        self.right = None

class Network:
    def __init__(self):
        self.nodes = {}

    def get_or_add_node(self, name):
        if name not in self.nodes:
            self.nodes[name] = Node(name)
        return self.nodes[name]

class Puzzle:
    def __init__(self, filename):
        try:
            input_file = open(filename, "r")
        except IOError as e:
            sys.exit(e)
        self.network = Network()
        self.instructions = ""
        for line in input_file:
            if not self.instructions:
                self.instructions = line.strip()
            else:
                if m := re.match(r"([0-9A-Z]+) = \(([0-9A-Z]+), ([0-9A-Z]+)\)", line):
                    n = self.network.get_or_add_node(m.group(1))
                    n.left = self.network.get_or_add_node(m.group(2))
                    n.right = self.network.get_or_add_node(m.group(3))
        input_file.close()

    def steps_to_end(self, node):
        i = 0
        while not node.name.endswith("Z"):
            if self.instructions[i % len(self.instructions)] == 'L':
                node = node.left
            else:
                node = node.right
            i += 1
        return i

    def solve(self):
        start_nodes = list(filter(lambda n: n.name.endswith("A"), self.network.nodes.values()))
        return math.lcm(*list(map(lambda n: self.steps_to_end(n), start_nodes)))


if len(sys.argv) < 2:
    sys.exit("Usage:  %s input.txt" % sys.argv[0])

print("Number of steps: %d" % Puzzle(sys.argv[1]).solve())