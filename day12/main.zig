const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

const Point = struct { x: usize, y: usize, value: u8 };
const Corner = struct { x: isize, y: isize };

const Garden = struct {
    points: []Point,

    fn contains(self: *const Garden, pp: Point) bool {
        for (self.points) |point| {
            if (point.x == pp.x and point.y == pp.y) {
                return true;
            }
        }
        return false;
    }

    fn containsCorner(self: *const Garden, pp: Corner) bool {
        for (self.points) |point| {
            if (point.x == pp.x and point.y == pp.y) {
                return true;
            }
        }
        return false;
    }

    pub fn value(self: *const Garden) usize {
        const area = self.points.len;
        var perimeter: usize = 0;

        for (self.points) |point| {
            var local: usize = 4;

            if (point.x > 0) {
                const up = Point{ .x = point.x - 1, .y = point.y, .value = ' ' };
                if (self.contains(up)) {
                    local -= 1;
                }
            }

            if (point.y > 0) {
                const left = Point{ .x = point.x, .y = point.y - 1, .value = ' ' };
                if (self.contains(left)) {
                    local -= 1;
                }
            }

            const down = Point{ .x = point.x + 1, .y = point.y, .value = ' ' };
            if (self.contains(down)) {
                local -= 1;
            }

            const right = Point{ .x = point.x, .y = point.y + 1, .value = ' ' };
            if (self.contains(right)) {
                local -= 1;
            }
            perimeter += local;
        }

        return area * perimeter;
    }

    pub fn value2(self: *const Garden) usize {
        const area = self.points.len;
        var sides: usize = 0;

        for (self.points) |point| {
            // print("Testing Point: ({}, {})\n", .{ point.x, point.y });
            const topLeft = Corner{ .x = @as(isize, @bitCast(point.x)) - 1, .y = @as(isize, @bitCast(point.y)) - 1 };
            const topRight = Corner{ .x = @as(isize, @bitCast(point.x)) + 1, .y = @as(isize, @bitCast(point.y)) - 1 };
            const bottomLeft = Corner{ .x = @as(isize, @bitCast(point.x)) - 1, .y = @as(isize, @bitCast(point.y)) + 1 };
            const bottomRight = Corner{ .x = @as(isize, @bitCast(point.x)) + 1, .y = @as(isize, @bitCast(point.y)) + 1 };
            const top = Corner{ .x = @bitCast(point.x), .y = @as(isize, @bitCast(point.y)) - 1 };

            const left = Corner{ .x = @as(isize, @bitCast(point.x)) - 1, .y = @bitCast(point.y) };

            const right = Corner{ .x = @as(isize, @bitCast(point.x)) + 1, .y = @bitCast(point.y) };
            const bottom = Corner{ .x = @as(isize, @bitCast(point.x)), .y = @as(isize, @bitCast(point.y)) + 1 };

            const bTop = self.containsCorner(top);
            const bLeft = self.containsCorner(left);
            const bRight = self.containsCorner(right);
            const bBottom = self.containsCorner(bottom);
            const bTopleft = self.containsCorner(topLeft);
            const bTopRight = self.containsCorner(topRight);
            const bBottomLeft = self.containsCorner(bottomLeft);
            const bBottomRight = self.containsCorner(bottomRight);

            // Top left is a crorner
            // print("bTop: {}, bLeft: {}, bTopleft: {}, result: {}\n", .{ bTop, bLeft, bTopleft, bTop == bLeft and !bTopleft });
            if (bTop == bLeft and !bTopleft) {
                sides += 1;
            }

            // Top right is a corner
            // print("bTop: {}, bRight: {}, bTopRight: {}, result: {}\n", .{ bTop, bRight, bTopRight, bTop == bRight and !bTopRight });
            if (bTop == bRight and !bTopRight) {
                sides += 1;
            }

            // Bottom right is a corner
            // print("bBottom: {}, bRight: {}, bBottomRight: {}, result: {}\n", .{ bBottom, bRight, bBottomRight, bBottom == bRight and !bBottomRight });
            if (bBottom == bRight and !bBottomRight) {
                sides += 1;
            }

            // Bottom left is a corner
            // print("bBottom: {}, bLeft: {}, bBottomLeft: {}, result: {}\n", .{ bBottom, bLeft, bBottomLeft, bBottom == bLeft and !bBottomLeft });
            if (bBottom == bLeft and !bBottomLeft) {
                sides += 1;
            }

            // Diagnonal, counted twice becase this case creates 2 corners.
            if (bBottomRight and !bBottom and !bRight) {
                sides += 2;
            }

            // Diagnonal Mirrored
            if (bBottomLeft and !bBottom and !bLeft) {
                sides += 2;
            }
        }
        // print("Found {} sides\n", .{sides});
        return area * sides;
    }
};

const Puzzle = struct {
    grid: [][]u8,
    data: []Garden,

    pub fn print_puzzle(self: *const Puzzle) void {
        for (0..self.grid.len) |row| {
            for (0..self.grid[row].len) |col| {
                print("{c}", .{self.grid[row][col]});
            }
            print("\n", .{});
        }
    }
};

fn createGarden(grid: *[][]u8, visited: *ArrayList(usize), row: usize, col: usize) !Garden {
    const character = (grid.*)[row][col];
    // print("Starting to search on: {c}, ({},{})\n", .{ character, col, row });

    const point = Point{ .x = col, .y = row, .value = character };
    var neighbors = ArrayList(Point).init(allocator);
    try neighbors.append(point);

    var points = ArrayList(Point).init(allocator);

    while (neighbors.popOrNull()) |current| {
        // check if we have visited this place already
        const hash = current.y << 32 | current.x;
        if (std.mem.indexOfScalar(usize, visited.items, hash) != null) {
            continue;
        }
        if ((grid.*)[current.y][current.x] != character) {
            continue;
        }
        try points.append(current);
        try visited.append(hash);
        // print("    testing neighbot: ({},{}) with hash {}\n", .{ current.x, current.y, hash });

        // Top
        if (current.y > 0) {
            const top = Point{ .x = current.x, .y = current.y - 1, .value = (grid.*)[current.y - 1][current.x] };
            try neighbors.append(top);
        }

        // Left
        if (current.x > 0) {
            const left = Point{ .x = current.x - 1, .y = current.y, .value = (grid.*)[current.y][current.x - 1] };
            try neighbors.append(left);
        }

        // Right
        if (current.x < (grid.*)[0].len - 1) {
            const right = Point{ .x = current.x + 1, .y = current.y, .value = (grid.*)[current.y][current.x + 1] };
            try neighbors.append(right);
        }

        // Bottom
        if (current.y < (grid.*).len - 1) {
            const left = Point{ .x = current.x, .y = current.y + 1, .value = (grid.*)[current.y + 1][current.x] };
            try neighbors.append(left);
        }
    }

    return Garden{ .points = points.items };
}

fn readInput() !Puzzle {
    var it = std.mem.splitScalar(u8, data, '\n');

    var grid = ArrayList([]u8).init(allocator);
    var gardens = ArrayList(Garden).init(allocator);

    var row: usize = 0;
    while (it.next()) |line| {
        var rowItems = ArrayList(u8).init(allocator);
        for (line) |character| {
            try rowItems.append(character);
        }
        try grid.append(rowItems.items);
        row += 1;
    }

    var visited = ArrayList(usize).init(allocator);
    for (grid.items, 0..) |rows, rowI| {
        for (rows, 0..) |_, col| {
            const hash = rowI << 32 | col;
            if (std.mem.indexOfScalar(usize, visited.items, hash) != null) {
                continue;
            }
            const garden = try createGarden(&grid.items, &visited, rowI, col);
            try gardens.append(garden);
        }
    }

    return Puzzle{ .grid = grid.items, .data = gardens.items };
}

const data = @embedFile("test.txt");
// const data = @embedFile("input.txt");

fn part1() !void {
    print("  part1:\n", .{});
    const p = try readInput();
    var sum: usize = 0;
    for (p.data) |g| {
        sum += g.value();
    }
    print("  Result: {}\n", .{sum});
}

fn part2() !void {
    print("  part2:\n", .{});
    const p = try readInput();
    var sum: usize = 0;
    for (p.data) |g| {
        // print("  Garden {c}\n", .{g.points[0].value});
        const v = g.value2();
        // print("  Garden {c} Result: {}\n", .{ g.points[0].value, v });
        sum += v;
    }
    print("  Result: {}\n", .{sum});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
