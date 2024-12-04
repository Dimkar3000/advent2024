const std = @import("std");
const print = @import("std").debug.print;
const fs = @import("std").fs;

const eql = std.mem.eql;
const ArrayList = std.ArrayList;

const Puzzle = struct {
    left: ArrayList(i32),
    right: ArrayList(i32),
};

fn read_input(filename: []const u8) !Puzzle {
    // print("{s}\n", .{filename});
    var file = try fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var puzzle: Puzzle = .{
        .left = ArrayList(i32).init(std.heap.page_allocator),
        .right = ArrayList(i32).init(std.heap.page_allocator),
    };

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitSequence(u8, line, "   ");

        const left = it.next().?;
        const leftInt = try std.fmt.parseInt(i32, left, 10);

        const right = it.next().?;
        const rightInt = try std.fmt.parseInt(i32, right, 10);

        try puzzle.left.append(leftInt);
        try puzzle.right.append(rightInt);
    }

    std.mem.sort(i32, puzzle.left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, puzzle.right.items, {}, comptime std.sort.asc(i32));
    return puzzle;
}

fn part1() !void {
    print("  part1: ", .{});
    const puzzle = try read_input("part1.txt");

    var sum: u32 = 0;
    for (0..puzzle.left.items.len) |index| {
        sum += @abs(puzzle.left.items[index] - puzzle.right.items[index]);
    }

    print("{}\n", .{sum});
}

fn part2() !void {
    print("  part2: ", .{});
    const puzzle = try read_input("part1.txt");

    var map = std.AutoHashMap(i32, i32).init(std.heap.page_allocator);
    for (puzzle.right.items) |item| {
        const old: ?i32 = map.get(item);
        if (old != null) {
            try map.put(item, old.? + 1);
        } else {
            try map.put(item, 1);
        }
    }

    var sum: i32 = 0;
    for (puzzle.left.items) |item| {
        const v = map.get(item);
        if (v != null) {
            sum += item * v.?;
        }
    }
    print("{}\n", .{sum});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    _ = try part1();
    try part2();
}
