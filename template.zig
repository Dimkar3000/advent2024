const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

const data = @embedFile("test.txt");
// const data = @embedFile("input.txt");

fn part1() !void {
    print("  part1:\n", .{});
}

fn part2() !void {
    print("  part2:\n", .{});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
