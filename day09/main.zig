const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

const NONE: u64 = 1 << 63;

const Puzzle = struct {
    memory: []u64,

    pub fn print_puzzle(self: *const Puzzle) void {
        for (self.memory) |c| {
            if (c == NONE) {
                print("_._", .{});
            } else {
                print("_{d}_", .{c});
            }
        }
        print("\n", .{});
    }

    pub fn sum(self: *const Puzzle) u64 {
        var result: u64 = 0;
        for (self.memory, 0..) |c, index| {
            if (c == NONE) {
                continue;
            }
            // print("sum: {} += {} * {}\n", .{ result, c, index });
            result += c * index;
        }
        return result;
    }

    pub fn part1(self: *const Puzzle) void {
        var left: usize = 0;
        while (self.memory[left] != NONE) {
            left += 1;
        }

        var i = self.memory.len - 1;
        while (self.memory[i] == NONE) {
            i -= 1;
        }

        while (i >= left) {
            self.memory[left] = self.memory[i];
            self.memory[i] = NONE;
            while (self.memory[i] == NONE) {
                i -= 1;
            }
            while (self.memory[left] != NONE) {
                left += 1;
            }
        }
    }
    
    fn set_range(self: *Puzzle, base: u64, direction: i64, length: u64, value: u64) void {
        var i = length;
        var index: i64 = @bitCast(base);
        while (i > 0) {
            // print("i: {}\n", .{i});
            self.memory[@bitCast(index)] = value;
            index += direction;
            i -= 1;
        }
    }

    fn find_legth(self: *const Puzzle, base: u64, direction: i64, value: u64) u64 {
        var i: u64 = 0;
        var index: i64 = @bitCast(base);
        while (self.memory[@bitCast(index)] == value) {
            index += direction;
            i += 1;
        }
        return i;
    }

    fn find_spot(self: *const Puzzle, base: u64, size: u64, end: u64) ?u64 {
        var currentSize: u64 = 0;
        var result: ?u64 = base;
        for (self.memory[base..], base..) |id, index| {
            // print("currentSize: {}\n", .{currentSize});
            if (id == NONE) {
                currentSize += 1;
            } else {
                currentSize = 0;
                result = index + 1;
            }
            if (currentSize >= size) {
                break;
            }
            if (index >= end) {
                return null;
            }
        }
        return result;
    }

    pub fn part2(self: *Puzzle) void {
        var left: usize = 0;
        var right = self.memory.len - 1;
        while (left < right) {
            var idRight = self.memory[right];
            while (idRight == NONE) {
                right -= 1;
                idRight = self.memory[right];
            }

            const sizeRight = self.find_legth(right, -1, idRight);
            const pos = self.find_spot(0, sizeRight, right - sizeRight);
            if (pos == null) {
                right = right - sizeRight;
                continue;
            }

            self.set_range(right, -1, sizeRight, NONE);
            self.set_range(pos.?, 1, sizeRight, idRight);
            left += sizeRight;
            while (self.memory[left] == NONE) {
                left += 1;
            }
        }
    }
};

fn read_input() !Puzzle {
    var sum: usize = 0;
    for (data) |c| {
        // print("c: {c}\n", .{c});
        const n = c - '0';
        sum += n;
    }
    // print("memory size: {}\n", .{sum});

    const memory = try allocator.alloc(u64, sum);

    var id: usize = 0;
    var index: usize = 0;

    var is_file = true;
    for (data) |c| {
        const n = c - '0';
        // print("\nc: {c}\n", .{c});
        // print("n: {d}\n", .{n});
        if (is_file) {
            for (0..n) |_| {
                memory[index] = @intCast(id);
                index += 1;
            }
            is_file = false;
            id += 1;
        } else {
            for (0..n) |_| {
                memory[index] = NONE;
                index += 1;
            }
            is_file = true;
        }
    }

    return Puzzle{ .memory = memory };
}

// const data = @embedFile("test.txt");
const data = @embedFile("input.txt");

fn part1() !void {
    print("  part1:\n", .{});
    var p = try read_input();
    // p.print_puzzle();
    p.part1();
    // p.print_puzzle();
    const sum = p.sum();
    print("  Result: {}\n", .{sum});
}

fn part2() !void {
    print("  part2:\n", .{});
    var p = try read_input();
    // p.print_puzzle();
    p.part2();
    // p.print_puzzle();
    const sum = p.sum();
    print("  Result: {}\n", .{sum});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
