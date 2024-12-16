const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

const Equation = struct {
    ax: i64,
    ay: i64,
    bx: i64,
    by: i64,
    prizex: i64,
    prizey: i64,

    pub fn solve(self: *const Equation, base: i64) i64 {
        const a = @divTrunc((self.prizex + base) * self.by - (self.prizey + base) * self.bx, self.ax * self.by - self.ay * self.bx);
        const b = @divTrunc(self.ax * (self.prizey + base) - self.ay * (self.prizex + base), self.ax * self.by - self.ay * self.bx);
        if (a * self.ax + b * self.bx == (self.prizex + base) and a * self.ay + b * self.by == (self.prizey + base)) {
            return 3 * a + b;
        }
        return 0;
    }
};

const Puzzle = struct { equations: []Equation };

fn readEquation(section: []const u8) !Equation {
    var parts = std.mem.splitAny(u8, section, "+=,\n");
    _ = parts.next().?;
    const a_x = parts.next().?;
    _ = parts.next().?;
    const a_y = parts.next().?;
    // print("\nax: {s}\n", .{a_x});
    // print("ay: {s}\n", .{a_y});

    _ = parts.next().?;
    const b_x = parts.next().?;
    _ = parts.next().?;
    const b_y = parts.next().?;
    // print("bx: {s}\n", .{b_x});
    // print("by: {s}\n", .{b_y});

    _ = parts.next().?;
    const price_x = parts.next().?;
    _ = parts.next().?;
    const price_y = parts.next().?;
    // print("pricex: {s}\n", .{price_x});
    // print("pricey: {s}\n", .{price_y});

    return Equation{
        .ax = try std.fmt.parseInt(i64, a_x, 10),
        .ay = try std.fmt.parseInt(i64, a_y, 10),
        .bx = try std.fmt.parseInt(i64, b_x, 10),
        .by = try std.fmt.parseInt(i64, b_y, 10),
        .prizex = try std.fmt.parseInt(i64, price_x, 10),
        .prizey = try std.fmt.parseInt(i64, price_y, 10),
    };
}

fn readInput() !Puzzle {
    var result = ArrayList(Equation).init(allocator);

    var it = std.mem.split(u8, data, "\n\n");
    while (it.next()) |section| {
        const eq = try readEquation(section);
        try result.append(eq);
    }

    return Puzzle{ .equations = result.items };
}

// const data = @embedFile("test.txt");
const data = @embedFile("input.txt");

fn part1() !void {
    print("  part1:\n", .{});
    const p = try readInput();
    var sum: i64 = 0;
    for (p.equations) |value| {
        sum += value.solve(0);
    }
    print("  Result: {}\n", .{sum});
}

fn part2() !void {
    print("  part2:\n", .{});
    const p = try readInput();
    var sum: i64 = 0;
    for (p.equations) |value| {
        sum += value.solve(10000000000000);
    }
    print("  Result: {}\n", .{sum});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
