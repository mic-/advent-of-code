/*
 * Advent of Code 2023 - Day 10: Pipe Maze, part 1
 * /Mic, 2023
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;

namespace Advent10_1
{
    [Flags]
    enum Direction
    {
        North = 1,
        South = 2,
        West = 4,
        East = 8,
        Unknown = North|South|West|East
    }

    class Endpoint
    {
        public Pipe connection = null;
    }

    class Pipe
    {
        public int x, y;
        public Endpoint north, south, west, east;
        public bool inspected = false;

        Pipe(int x, int y, Direction directions)
        {
            this.x = x;
            this.y = y;
            north = ((directions & Direction.North) != 0) ? new Endpoint() : null;
            south = ((directions & Direction.South) != 0) ? new Endpoint() : null;
            west = ((directions & Direction.West) != 0) ? new Endpoint() : null;
            east = ((directions & Direction.East) != 0) ? new Endpoint() : null;
        }

        public Endpoint[] GetEndpoints() { return new Endpoint[] { north, south, west, east}; }

        public Pipe[] GetConnections() { return GetEndpoints().Select(e => e?.connection).Where(c => c != null).ToArray(); }

        public bool IsStart() { return GetEndpoints().Count(e => e != null) == 4; }

        public void TryConnect(Pipe other)
        {
            if (other == null) return;
            Endpoint e1 = null, e2 = null;
            if (x == other.x && y == other.y-1)
            {
                e1 = south; e2 = other.north;
            } else if (x == other.x && y == other.y+1)
            {
                e1 = north; e2 = other.south;
            } else if (y == other.y && x == other.x-1)
            {
                e1 = east; e2 = other.west;
            } else if (y == other.y && x == other.x+1)
            {
                e1 = west; e2 = other.east;
            }
            if (e1 != null && e2 != null)
            {
                e1.connection = other; e2.connection = this;
            }
        }

        public static Pipe FromChar(char ch, int x, int y)
        {
            switch (ch)
            {
                case '|': return new Pipe(x, y, Direction.North|Direction.South);
                case '-': return new Pipe(x, y, Direction.West|Direction.East);
                case 'L': return new Pipe(x, y, Direction.North|Direction.East);
                case 'J': return new Pipe(x, y, Direction.North|Direction.West);
                case '7': return new Pipe(x, y, Direction.South|Direction.West);
                case 'F': return new Pipe(x, y, Direction.South|Direction.East);
                case 'S': return new Pipe(x, y, Direction.Unknown);
                default: return null;
            }
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                Console.WriteLine("Error: No input file specified");
                return;
            }
            string[] lines = File.ReadAllLines(args[0]);

            List<List<Pipe>> map = new List<List<Pipe>>();
            Pipe start = null;
            foreach (string line in lines)
            {
                List<Pipe> row = line.Trim().Select((ch, index) => Pipe.FromChar(ch, index, map.Count)).ToList();
                start = (start != null) ? start : row.Find(p => p?.IsStart() == true);
                map.Add(row);
            }

            for (int y = 0; y < map.Count; y++)
            {
                for (int x = 0; x < map[y].Count; x++)
                {
                    if (y > 0) map[y][x]?.TryConnect(map[y - 1][x]);
                    if (x > 0) map[y][x]?.TryConnect(map[y][x - 1]);
                    if (y < map.Count-1) map[y][x]?.TryConnect(map[y + 1][x]);
                    if (x < map[y].Count-1) map[y][x]?.TryConnect(map[y][x + 1]);
                }
            }

            UInt64 steps = 1;
            Pipe[] next = start.GetConnections();
            start.inspected = true;
            while (next[0] != next[1])
            {
                next[0].inspected = true;
                next[1].inspected = true;
                steps++;
                next[0] = next[0].GetConnections().Where(p => !p.inspected).First();
                next[1] = next[1].GetConnections().Where(p => !p.inspected).First();
            }

            Console.WriteLine(steps);
        }
    }
}
