const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

// const data = @embedFile("test.txt");
const data = @embedFile("input.txt");

const Point = struct {
    x: isize,
    y: isize,
};

const Puzzle = struct {
    grid: [][]const u8,
    letterToPoints: HashMap(u8, ArrayList(Point)),

    pub fn print_puzzle(self: *const Puzzle) void {
        var it = self.letterToPoints.iterator();
        while (it.next()) |entry| {
            print("Point: {c}, Positions: ", .{entry.key_ptr.*});
            for (entry.value_ptr.items) |point| {
                print(" ({}, {}),", .{ point.x, point.y });
            }
            print("\x1b[\x08m \n", .{});
        }
    }
};

fn read_input() !Puzzle {
    var lines = std.mem.splitScalar(u8, data, '\n');

    var row: isize = 0;
    var pps = HashMap(u8, ArrayList(Point)).init(allocator);
    var grid = ArrayList([]const u8).init(allocator);
    while (lines.next()) |line| {
        try grid.append(line);
        for (line, 0..) |character, col| {
            if (character != '.') {
                var key = try pps.getOrPutValue(character, ArrayList(Point).init(allocator));
                const point = Point{ .x = @bitCast(col), .y = @bitCast(row) };
                try key.value_ptr.append(point);
            }
        }
        row += 1;
    }

    return Puzzle{ .grid = grid.items, .letterToPoints = pps };
}

fn part1() !void {
    print("  part1:\n", .{});
    const puzzle = try read_input();
    // puzzle.print_puzzle();

    var sum: isize = 0;
    var it = puzzle.letterToPoints.iterator();
    var found = ArrayList(isize).init(allocator);
    while (it.next()) |entry| {
        // sum += @as(isize, @bitCast(entry.value_ptr.items.len));
        for (entry.value_ptr.items, 0..) |point, index| {
            if (index >= entry.value_ptr.items.len - 1) {
                break;
            }
            const x = point.x;
            const y = point.y;
            for (entry.value_ptr.items[index + 1 ..]) |other| {
                const vx = other.x - x;
                const vy = -other.y + y;
                // print("\nStart: ({},{})\n", .{ x, y });
                // print("End: ({},{})\n", .{ other.x, other.y });
                // print("Vector: ({},{})\n", .{ vx, vy });

                const c1x = x - vx;
                const c1y = y + vy;
                // print("C1: ({},{})\n", .{ c1x, c1y });
                // of the grid
                if (c1x >= 0 and c1x < puzzle.grid[0].len and c1y >= 0 and c1y < puzzle.grid.len) {
                    const key: isize = c1x * 100000 + c1y;
                    if (std.mem.indexOfScalar(isize, found.items, key) == null) {
                        try found.append(key);
                        sum += 1;
                    }
                }

                const c2x = other.x + vx;
                const c2y = other.y - vy;
                // print("C2: ({},{})\n", .{ c2x, c2y });
                // of the grid
                if (c2x >= 0 and c2x < puzzle.grid[0].len and c2y >= 0 and c2y < puzzle.grid.len) {
                    const key = c2x * 100000 + c2y;
                    if (std.mem.indexOfScalar(isize, found.items, key) == null) {
                        try found.append(key);
                        sum += 1;
                    }
                }
            }
        }
    }
    print("  Result: {}\n", .{sum});
}

fn part2() !void {
    print("  part2:\n", .{});
    const puzzle = try read_input();
    // puzzle.print_puzzle();

    var sum: isize = 0;
    var it = puzzle.letterToPoints.iterator();
    var found = ArrayList(isize).init(allocator);
    while (it.next()) |entry| {
        for (entry.value_ptr.items, 0..) |point, index| {
            if (index >= entry.value_ptr.items.len - 1) {
                break;
            }
            const x = point.x;
            const y = point.y;
            for (entry.value_ptr.items[index + 1 ..]) |other| {
                const vx = other.x - x;
                const vy = -other.y + y;
                // print("\nStart: ({},{})\n", .{ x, y });
                // print("End: ({},{})\n", .{ other.x, other.y });
                // print("Vector: ({},{})\n", .{ vx, vy });

                for (0..100) |harmonic| {
                    const c1xh = x - vx * @as(isize, @bitCast(harmonic));
                    const c1yh = y + vy * @as(isize, @bitCast(harmonic));
                    // print("Testing Harmonic {} with values ({}, {})\n", .{ harmonic, c1xh, c1yh });
                    if (c1xh >= 0 and c1xh < puzzle.grid[0].len and c1yh >= 0 and c1yh < puzzle.grid.len) {
                        const key: isize = c1xh * 100000 + c1yh;
                        if (std.mem.indexOfScalar(isize, found.items, key) == null) {
                            try found.append(key);
                            sum += 1;
                        }
                    } else {
                        break;
                    }
                }

                for (0..100) |harmonic| {
                    const c2xh = other.x + vx * @as(isize, @bitCast(harmonic));
                    const c2yh = other.y - vy * @as(isize, @bitCast(harmonic));
                    // print("Testing Harmonic {} with values ({}, {})\n", .{ harmonic, c2xh, c2yh });
                    if (c2xh >= 0 and c2xh < puzzle.grid[0].len and c2yh >= 0 and c2yh < puzzle.grid.len) {
                        const key = c2xh * 100000 + c2yh;
                        if (std.mem.indexOfScalar(isize, found.items, key) == null) {
                            try found.append(key);
                            sum += 1;
                        }
                    } else {
                        break;
                    }
                }
            }
        }
    }
    print("  Result: {}\n", .{sum});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
