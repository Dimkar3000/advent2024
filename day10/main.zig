const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

const Point = struct { x: usize, y: usize, height: usize };

const Puzzle = struct {
    map: [][]Point,
    startingPost: []Point,

    pub fn print_puzzle(self: *const Puzzle) void {
        print("Map: \n", .{});
        for (self.map) |row| {
            for (row) |point| {
                print("{}", .{point.height});
            }
            print("\n", .{});
        }
        print("Starting positions: \n", .{});
        for (self.startingPost) |pos| {
            print("({}, {}, {})\n", .{ pos.x, pos.y, pos.height });
        }
        print("\n", .{});
    }

    fn find_neighbors(self: *const Puzzle, start: Point) [4]?Point {
        var leftPoint: ?Point = null;
        var rightPoint: ?Point = null;
        var topPoint: ?Point = null;
        var bottomPoint: ?Point = null;

        if (start.x > 0) {
            leftPoint = Point{ .x = start.x - 1, .y = start.y, .height = start.height };
            leftPoint.?.height = self.map[leftPoint.?.y][leftPoint.?.x].height;
            // print("found left: {},{}, {}\n", .{ leftPoint.?.x, leftPoint.?.y, leftPoint.?.height });
        }
        if (start.x < self.map[0].len - 1) {
            rightPoint = Point{ .x = start.x + 1, .y = start.y, .height = start.height };
            rightPoint.?.height = self.map[rightPoint.?.y][rightPoint.?.x].height;
            // print("found right: {},{}, {}\n", .{ rightPoint.?.x, rightPoint.?.y, rightPoint.?.height });
        }
        if (start.y > 0) {
            topPoint = Point{ .x = start.x, .y = start.y - 1, .height = start.height };
            topPoint.?.height = self.map[topPoint.?.y][topPoint.?.x].height;
            // print("found top: {},{}, {}\n", .{ topPoint.?.x, topPoint.?.y, topPoint.?.height });
        }
        if (start.y < self.map.len - 1) {
            bottomPoint = Point{ .x = start.x, .y = start.y + 1, .height = start.height };
            bottomPoint.?.height = self.map[bottomPoint.?.y][bottomPoint.?.x].height;
            // print("found bottom: {},{}, {}\n", .{ bottomPoint.?.x, bottomPoint.?.y, bottomPoint.?.height });
        }

        return .{ leftPoint, rightPoint, bottomPoint, topPoint };
    }

    pub fn findScore(self: *const Puzzle, start: Point) !usize {
        var currentPoints = ArrayList(Point).init(allocator);
        var results = ArrayList(Point).init(allocator);
        try currentPoints.append(start);

        while (currentPoints.items.len > 0) {
            const currentPoint = currentPoints.pop();
            const currentHeight = currentPoint.height;
            // print("\neval: {},{}\n", .{ currentPoint.x, currentPoint.y });

            if (currentHeight == 9) {
                // print("found: {},{}\n", .{ currentPoint.x, currentPoint.y });
                try add_unique(&results, currentPoint);
                continue;
            }

            const neighs = self.find_neighbors(currentPoint);
            for (neighs) |n| {
                if (n != null and n.?.height == currentHeight + 1) {
                    // print("found neighbor: {},{}\n", .{ n.?.x, n.?.y });
                    try currentPoints.append(n.?);
                }
            }
        }

        return results.items.len;
    }

    pub fn findScore2(self: *const Puzzle, start: Point) !usize {
        var currentPoints = ArrayList(Point).init(allocator);
        var results = ArrayList(Point).init(allocator);
        try currentPoints.append(start);

        while (currentPoints.items.len > 0) {
            const currentPoint = currentPoints.pop();
            const currentHeight = currentPoint.height;
            // print("\neval: {},{}\n", .{ currentPoint.x, currentPoint.y });

            if (currentHeight == 9) {
                // print("found: {},{}\n", .{ currentPoint.x, currentPoint.y });
                try results.append(currentPoint);
                continue;
            }

            const neighs = self.find_neighbors(currentPoint);
            for (neighs) |n| {
                if (n != null and n.?.height == currentHeight + 1) {
                    // print("found neighbor: {},{}\n", .{ n.?.x, n.?.y });
                    try currentPoints.append(n.?);
                }
            }
        }

        return results.items.len;
    }

    pub fn part1(self: *const Puzzle) !usize {
        var sum: usize = 0;
        for (self.startingPost) |point| {
            sum += try self.findScore(point);
        }

        return sum;
    }

    pub fn part2(self: *const Puzzle) !usize {
        var sum: usize = 0;
        for (self.startingPost) |point| {
            sum += try self.findScore2(point);
        }

        return sum;
    }
};

fn add_unique(list: *ArrayList(Point), new: Point) !void {
    for (list.items) |p| {
        if (p.x == new.x and p.y == new.y) {
            return;
        }
    }
    try list.append(new);
}

fn read_input() !Puzzle {
    var map = ArrayList([]Point).init(allocator);
    var startingPositions = ArrayList(Point).init(allocator);

    var col: usize = 0;
    var row: usize = 0;
    var index: usize = 0;
    var mapRow = ArrayList(Point).init(allocator);
    while (index < data.len) {
        const character: u8 = data[index];
        if (character == '\n') {
            row += 1;
            col = 0;
            index += 1;
            try map.append(mapRow.items);
            mapRow = ArrayList(Point).init(allocator);
            continue;
        }
        const height = character - '0';
        const point = Point{ .x = col, .y = row, .height = height };
        try mapRow.append(point);

        if (height == 0) {
            try startingPositions.append(point);
        }

        index += 1;
        col += 1;
    }
    try map.append(mapRow.items);

    return Puzzle{ .map = map.items, .startingPost = startingPositions.items };
}
// const data = @embedFile("test.txt");
const data = @embedFile("input.txt");

fn part1() !void {
    print("  part1:\n", .{});
    const p = try read_input();
    // p.print_puzzle();
    const sum = try p.part1();
    print("  Result: {}\n", .{sum});
}

fn part2() !void {
    print("  part2:\n", .{});
    const p = try read_input();
    // p.print_puzzle();
    const sum = try p.part2();
    print("  Result: {}\n", .{sum});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
