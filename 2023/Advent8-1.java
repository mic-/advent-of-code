/*
 * Advent of Code 2023 - Day 8: Haunted Wasteland, part 1
 * Mic, 2023
 */

import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.Scanner;
import java.util.regex.Pattern;

class Advent8_1 {
    static class Node {
        Node(String name, Node left, Node right) { this.name = name; this.left = left; this.right = right; }
        Node(String name) { this(name, null, null); }
        public final String name;
        public Node left, right;
    }

    static class Network {
        Node getOrAddNode(final String name) {
            final Node empty = new Node(name);
            final Node existing = nodes.putIfAbsent(name, empty);
            return (existing != null) ? existing : empty;
        }

        public final HashMap<String, Node> nodes = new HashMap<>();
    }

    record Puzzle(Network network, String instructions) {
        int solve() {
            var node = network.nodes.get("AAA");
            var steps = 0;
            while (! node.name.equals("ZZZ")) {
                var direction = instructions.charAt(steps % instructions.length());
                steps++;
                node = (direction == 'L') ? node.left : node.right;
            }
            return steps;
        }

        static Puzzle fromFile(String filename) throws FileNotFoundException {
            String instructions;
            var network = new Network();

            var file = new File(filename);
            try (var input = new Scanner(file)) {
                instructions = input.nextLine();
                var pattern = Pattern.compile("([A-Z]+) = \\(([A-Z]+), ([A-Z]+)\\)", Pattern.CASE_INSENSITIVE);
                while (input.hasNextLine()) {
                    var line = input.nextLine();
                    var matcher = pattern.matcher(line);
                    if (matcher.matches()) {
                        if (matcher.groupCount() == 3) {
                            var node = network.getOrAddNode(matcher.group(1));
                            node.left = network.getOrAddNode(matcher.group(2));
                            node.right = network.getOrAddNode(matcher.group(3));
                        }
                    }
                }
            }
            return new Puzzle(network, instructions);
        }
    }

    public static void main(String[] args) throws FileNotFoundException {
        if (args.length == 0) {
            System.out.println("Error: No input file specified");
            return;
        }
        System.out.println("Number of steps: " + Puzzle.fromFile(args[0]).solve());
    }
}