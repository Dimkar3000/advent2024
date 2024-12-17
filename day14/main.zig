const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

const Robot = struct {
    position_x: isize,
    position_y: isize,
    velocity_x: isize,
    velocity_y: isize,

    pub fn print_robot(self: *const Robot) void {
        print("p={},{} v={},{}\n", .{ self.position_x, self.position_y, self.velocity_x, self.velocity_y });
    }

    pub fn move(self: *Robot, grid_x: isize, grid_y: isize) void {
        // X Axis
        if (self.velocity_x < 0 and self.position_x < -self.velocity_x) {
            self.position_x = grid_x - (-self.velocity_x - self.position_x);
        } else if (self.velocity_x > 0 and self.position_x + self.velocity_x >= grid_x) {
            self.position_x = self.position_x + self.velocity_x - grid_x;
        } else {
            self.position_x += self.velocity_x;
        }

        // y Axis
        if (self.velocity_y < 0 and self.position_y < -self.velocity_y) {
            self.position_y = grid_y - (-self.velocity_y - self.position_y);
        } else if (self.velocity_y > 0 and self.position_y + self.velocity_y >= grid_y) {
            self.position_y = self.position_y + self.velocity_y - grid_y;
        } else {
            self.position_y += self.velocity_y;
        }
    }
};

const Puzzle = struct {
    robots: []Robot,

    pub fn print_puzzle(self: *const Puzzle) void {
        for (self.robots) |robot| {
            robot.print_robot();
        }
    }

    pub fn no_overlaps(self: *const Puzzle) !bool {
        var visited = ArrayList(i64).init(allocator);
        for (self.robots) |robot| {
            const hash = robot.position_x * 10000 + robot.position_y;
            if (std.mem.indexOfScalar(i64, visited.items, hash) != null) {
                return false;
            }
            try visited.append(hash);
        }
        return true;
    }

    pub fn part1(self: *const Puzzle, grid_x: isize, grid_y: isize) i64 {
        var topLeft: i64 = 0;
        var topRight: i64 = 0;
        var bottomLeft: i64 = 0;
        var bottomRight: i64 = 0;

        for (self.robots) |robot| {
            // robot.print_robot();
            if (robot.position_x < @divFloor(grid_x, 2) and robot.position_y < @divFloor(grid_y, 2)) {
                // print("topLeft\n", .{});
                topLeft += 1;
            }
            if (robot.position_x < @divFloor(grid_x, 2) and robot.position_y > @divFloor(grid_y, 2)) {
                // print("bottomLeft\n", .{});
                bottomLeft += 1;
            }
            if (robot.position_x > @divFloor(grid_x, 2) and robot.position_y < @divFloor(grid_y, 2)) {
                // print("topRight\n", .{});
                topRight += 1;
            }
            if (robot.position_x > @divFloor(grid_x, 2) and robot.position_y > @divFloor(grid_y, 2)) {
                // print("bottomRight\n", .{});
                bottomRight += 1;
            }
        }

        return topLeft * topRight * bottomLeft * bottomRight;
    }
};

fn readInput() !Puzzle {
    var it = std.mem.splitScalar(u8, data, '\n');

    var robots = ArrayList(Robot).init(allocator);

    while (it.next()) |line| {
        var parts = std.mem.splitAny(u8, line, "=, ");

        _ = parts.next();
        const px = parts.next().?;
        // print("\npx: {s}\n", .{px});

        const py = parts.next().?;
        _ = parts.next();
        // print("py: {s}\n", .{py});

        const vx = parts.next().?;
        // print("vx: {s}\n", .{vx});

        const vy = parts.next().?;
        // print("vy: {s}\n", .{vy});

        try robots.append(Robot{
            .position_x = try std.fmt.parseInt(isize, px, 10),
            .position_y = try std.fmt.parseInt(isize, py, 10),
            .velocity_x = try std.fmt.parseInt(isize, vx, 10),
            .velocity_y = try std.fmt.parseInt(isize, vy, 10),
        });
    }

    return Puzzle{
        .robots = robots.items,
    };
}
// const data = @embedFile("test.txt");
const data = @embedFile("input.txt");

fn part1() !void {
    print("  part1:\n", .{});
    // const grid_x = 11;
    // const grid_y = 7;
    const grid_x = 101;
    const grid_y = 103;
    var p = try readInput();
    for (0..100) |_| {
        for (0..p.robots.len) |i| {
            p.robots[i].move(grid_x, grid_y);
        }
    }

    const result = p.part1(grid_x, grid_y);
    print("  Result: {}\n", .{result});
}

fn part2() !void {
    print("  part2:\n", .{});
    // const grid_x = 11;
    // const grid_y = 7;
    const grid_x = 101;
    const grid_y = 103;
    var p = try readInput();

    var counter: usize = 0;
    while (!(try p.no_overlaps())) {
        counter += 1;
        for (0..p.robots.len) |i| {
            p.robots[i].move(grid_x, grid_y);
        }
    }

    print("  Result: {}\n", .{counter});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
