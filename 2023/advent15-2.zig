// Advent of Code 2023 - Day 15: Lens Library, part 2
// Mic, 2023

const std = @import("std");

const Allocator = std.mem.Allocator;

fn hash(str: []const u8) u32 {
    var result: u32 = 0;
    for (str) |c| {
        result = ((result + c) * 17) & 0xFF;
    }
    return result;
}

fn arrangeLenses(boxes: *std.AutoArrayHashMap(u32, *std.StringArrayHashMap(u32)), instructions: []u8, allocator: Allocator) !void {
    var steps = std.mem.split(u8, instructions, ",");
    while (steps.next()) |step| {
        if (std.mem.containsAtLeast(u8, step, 1, &[_]u8{'='})) {
            var it = std.mem.split(u8, step, "=");
            const label = it.next() orelse "";
            const focal_length = try std.fmt.parseInt(u32, it.next() orelse "", 10);
            const box = hash(label);
            if (!boxes.contains(box)) {
                var new_box = try allocator.create(std.StringArrayHashMap(u32));
                new_box.* = std.StringArrayHashMap(u32).init(allocator);
                try boxes.put(box, new_box);
            }
            try boxes.get(box).?.put(label, focal_length);
        } else if (std.mem.containsAtLeast(u8, step, 1, &[_]u8{'-'})) {
            var it = std.mem.split(u8, step, "-");
            const label = it.next() orelse "";
            const box = hash(label);
            if (boxes.contains(box)) {
                _ = boxes.get(box).?.orderedRemove(label);
            }
        }
    }
}

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(general_purpose_allocator.deinit() == .ok);
    const allocator = general_purpose_allocator.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len < 2) {
        std.debug.print("Usage: advent15-2 input.txt\n", .{});
        return;
    }

    var file = try std.fs.cwd().openFile(args[1], .{ .mode = .read_only });
    defer file.close();

    var contents = try file.readToEndAlloc(allocator, 100_000);
    defer allocator.free(contents);

    var boxes = std.AutoArrayHashMap(u32, *std.StringArrayHashMap(u32)).init(allocator);
    defer boxes.deinit();

    try arrangeLenses(&boxes, contents, allocator);

    var focusing_power: u64 = 0;
    for (boxes.keys()) |box_key| {
        const box = boxes.get(box_key).?;
        var lens_it = box.iterator();
        while (lens_it.next()) |lens_entry| {
            focusing_power += (box_key + 1) * (box.getIndex(lens_entry.key_ptr.*).? + 1) * lens_entry.value_ptr.*;
        }
        box.*.deinit();
        allocator.destroy(box);
    }
    std.debug.print("Total focusing power is {d}\n", .{focusing_power});
}