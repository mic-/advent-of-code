/*
 * Advent of Code 2024 - Day 9: Disk Fragmenter, part 1
 * Mic, 2024
 */

import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class Day9_1 {
    private static final int EMPTY = -1;

    record Disk(ArrayList<Integer> data) {
        int findNextFile(int offset) {
            for (int end = offset; end >= 0; end--) {
                if (data.get(end) != EMPTY) return end;
            }
            return -1;
        }

        int findFreeSpace(int offset) {
            for (int start = offset; start < data.size(); start++) {
                if (data.get(start) == EMPTY) return start;
            }
            return data.size();
        }

        Disk defragment() {
            var file = findNextFile(data.size() - 1);
            var free = findFreeSpace(0);
            while (free < file) {
                data.set(free, data.get(file));
                data.set(file, EMPTY);
                file = findNextFile(file - 1);
                free = findFreeSpace(free + 1);
            }
            return this;
        }

        long checksum() {
            long checksum = 0;
            for (int i = 0; i < data.size(); i++) {
                int id = data.get(i);
                checksum += (id != EMPTY) ? (long) id *i : 0;
            }
            return checksum;
        }

        static Disk fromFile(String filename) throws FileNotFoundException {
            var file = new java.io.File(filename);
            try (var input = new Scanner(file)) {
                var line = input.nextLine();
                var indices = IntStream.range(0, line.length()).boxed();
                var data = indices.map(i -> Collections.nCopies(line.charAt(i)-'0', (i & 1)==1 ? EMPTY : i>>1))
                        .flatMap(List::stream)
                        .collect(Collectors.toCollection(ArrayList::new));
                return new Disk(data);
            }
        }
    }
    public static void main(String[] args) throws FileNotFoundException {
        if (args.length == 0) {
            System.out.println("Error: No input file specified");
            return;
        }

        System.out.println("Filesystem checksum: " + Disk.fromFile(args[0]).defragment().checksum());
    }
}
