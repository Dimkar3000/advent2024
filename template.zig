const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

fn part1(filename: []const u8) !void {
    print("  part1:\n", .{});
    print("  filename: {s}\n", .{filename});
}

fn part2(filename: []const u8) !void {
    print("  part2:\n", .{});
    print("  filename: {s}\n", .{filename});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    const filename = "test.txt";
    try part1(filename);
    try part2(filename);
}
