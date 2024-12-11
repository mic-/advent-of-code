/*
 * Advent of Code 2024 - Day 9: Disk Fragmenter, part 2
 * Mic, 2024
 */

import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class Day9_2 {
    private static final int EMPTY = -1;

    record File(int start, int size) {}

    record Disk(ArrayList<Integer> data) {
        File findNextFile(int offset) {
            for (int end = offset; end >= 0; end--) {
                if (data.get(end) != EMPTY) {
                    int id = data.get(end);
                    int start = end;
                    while (start >= 0 && data.get(start) == id) start--;
                    return new File(start+1, end-start);
                }
            }
            return new File(-1, -1);
        }

        int findFreeSpace(int offset, int size) {
            for (int start = offset; start < data.size(); start++) {
                if (data.get(start) == EMPTY) {
                    for (int end = start; end < data.size(); end++) {
                        if (data.get(end) != EMPTY) break;
                        if (end == start+size-1) return start;
                    }
                }
            }
            return data.size();
        }

        Disk defragment() {
            var file = findNextFile(data.size()-1);
            var free1 = findFreeSpace(0, 1);
            var freeSz = findFreeSpace(free1, file.size);
            while (free1 < file.start) {
                if (freeSz < file.start) {
                    for (int i = 0; i < file.size; i++) {
                        data.set(freeSz + i, data.get(file.start + i));
                        data.set(file.start + i, EMPTY);
                    }
                }
                file = findNextFile(file.start - 1);
                free1 = findFreeSpace(free1, 1);
                freeSz = findFreeSpace(free1, file.size);
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
