const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

const Puzzle = struct {
    stones: HashMap(u64, u64),

    pub fn print_puzzle(self: *const Puzzle) void {
        var it = self.stones.iterator();
        while (it.next()) |entry| {
            for (0..entry.value_ptr) |_| {
                print("{} ", .{*entry.key_ptr});
            }
        }
        print("\n", .{});
    }
};

pub fn sum(current: *HashMap(u64, u64)) u64 {
    var it = current.iterator();
    var result: u64 = 0;
    while (it.next()) |entry| {
        result += entry.value_ptr.*;
    }
    return result;
}

pub fn step(current: *HashMap(u64, u64), next: *HashMap(u64, u64)) !void {
    next.*.clearRetainingCapacity();
    var it = current.iterator();
    while (it.next()) |entry| {
        const value = entry.key_ptr.*;
        const count = entry.value_ptr.*;

        if (value == 0) {
            const v = try next.getOrPutValue(1, 0);
            v.value_ptr.* += count;
            continue;
        }

        const digits = std.math.log_int(u64, 10, value) + 1;
        if (digits % 2 == 0) {
            const left = value / try std.math.powi(u64, 10, digits / 2);
            const right = value % try std.math.powi(u64, 10, digits / 2);
            const vLeft = try next.getOrPutValue(left, 0);
            vLeft.value_ptr.* += count;
            const vRgith = try next.getOrPutValue(right, 0);
            vRgith.value_ptr.* += count;
            continue;
        }

        const v = try next.getOrPutValue(value * 2024, 0);
        v.value_ptr.* += count;
    }
}

fn readInput() !Puzzle {
    var stones = HashMap(u64, u64).init(allocator);
    var it = std.mem.splitScalar(u8, data, ' ');
    while (it.next()) |item| {
        const value = try std.fmt.parseInt(u64, item, 10);
        const p = try stones.getOrPutValue(value, 0);
        p.value_ptr.* = p.value_ptr.* + 1;
    }

    return Puzzle{ .stones = stones };
}

// const data = @embedFile("test.txt");
const data = @embedFile("input.txt");

fn part1() !void {
    print("  part1:\n", .{});
    const p = try readInput();

    var current = p.stones;
    var next = HashMap(u64, u64).init(allocator);
    // p.print_puzzle();
    for (0..25) |_| {
        try step(&current, &next);
        std.mem.swap(HashMap(u64, u64), &current, &next);
    }
    // p.print_puzzle();
    print("  Result {}\n", .{sum(&current)});
}

fn part2() !void {
    print("  part2:\n", .{});
    const p = try readInput();
    var current = p.stones;
    var next = HashMap(u64, u64).init(allocator);
    // p.print_puzzle();
    for (0..75) |_| {
        try step(&current, &next);
        std.mem.swap(HashMap(u64, u64), &current, &next);
    }
    // p.print_puzzle();
    print("  Result {}\n", .{sum(&current)});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
