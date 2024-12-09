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

const PointAndDirection = struct {
    x: isize,
    y: isize,
    diretion_x: isize,
    diretion_y: isize,
};

const Puzzle = struct {
    grid: [][]bool, // True if the player can walk on it
    start_x: isize,
    start_y: isize,

    pub fn read_puzzle(self: *const Puzzle) void {
        for(self.grid, 0..) |rows, i| {
            for(rows, 0..) |character, j| {
                if(i == self.start_y and j == self.start_x) {
                    print("^", .{});
                }
                else if(character) {
                    print(".", .{});
                } else {
                    print("#", .{});
                }
            }
            print("\n", .{});
        }
    }

    pub fn collect_path(self: *const Puzzle) !ArrayList(Point) {
        var current_x = self.start_x;
        var current_y = self.start_y;

        // We start going up
        var current_direction_x: isize = 0; 
        var current_direction_y: isize = -1; 

        var visited = ArrayList(Point).init(allocator);
        var loc = Point{.x= current_x, .y= current_y};
        try visited.append(loc);

        // while I am not out of bounds
        while(current_x + current_direction_x < self.grid[0].len and current_y + current_direction_y < self.grid.len) {
            const test_x = current_x + current_direction_x;
            const test_y = current_y + current_direction_y;
            
            // if I can walk on the new cell then we do
            if (self.grid[@bitCast(test_y)][@bitCast(test_x)]) {
                current_x = test_x;
                current_y = test_y;
                // print("Waked: {}, {}, Current size: {}\n", .{current_x, current_y, visited.items.len});
                
                var contains = false;
                for(visited.items) |location| {
                    if(location.x == current_x and location.y == current_y) {
                        contains = true;
                        break;
                    }
                }
                if(!contains) {
                    loc = Point{.x= current_x, .y= current_y};
                    try visited.append(loc);
                } 
            } else {
                // We need to turn 90deg 

                // We were going up
                if(current_direction_x == 0 and current_direction_y == -1) {
                    current_direction_x = 1;
                    current_direction_y = 0;
                }

                // we were going right
                else if(current_direction_x == 1 and current_direction_y == 0) {
                    current_direction_x = 0;
                    current_direction_y = 1;
                }

                // we were going down
                else if(current_direction_x == 0 and current_direction_y == 1) {
                    current_direction_x = -1;
                    current_direction_y = 0;
                }

                // we were going left
                else if(current_direction_x == -1 and current_direction_y == 0) {
                    current_direction_x = 0;
                    current_direction_y = -1;
                }
            }
        }

        return visited;
    }

    fn is_loop(self: *const Puzzle, extraBlock: *const Point) !bool{
        var current_x = self.start_x;
        var current_y = self.start_y;

        // We start going up
        var current_direction_x: isize = 0; 
        var current_direction_y: isize = -1; 

        var visited = ArrayList(PointAndDirection).init(allocator);
        defer visited.deinit();
    
        var loc = PointAndDirection{.x= current_x, .y= current_y, .diretion_x = current_direction_x, .diretion_y = current_direction_y};
        try visited.append(loc);

        // while I am not out of bounds
        while(current_x + current_direction_x < self.grid[0].len and current_y + current_direction_y < self.grid.len) {
            const test_x = current_x + current_direction_x;
            const test_y = current_y + current_direction_y;

            if(test_x < 0 or test_y<0) {
                break;
            }
            
            // if I can walk on the new cell then we do
            const isNotObstacle = self.grid[@bitCast(test_y)][@bitCast(test_x)];

            if (isNotObstacle and (extraBlock.x != test_x or extraBlock.y != test_y)) {
                // print("Waked: {}, {}, Current size: {}\n", .{test_x, test_y, visited.items.len});
                // print("Previous: {}, {}, Current size: {}\n", .{current_x, current_y, visited.items.len});
                current_x = test_x;
                current_y = test_y;
                
                for(visited.items) |state| {
                    if(state.x == current_x and 
                        state.y == current_y and 
                        state.diretion_x == current_direction_x and 
                        state.diretion_y == current_direction_y) {
                        return true;
                    }
                }
                loc = PointAndDirection{.x= current_x, .y= current_y, .diretion_x = current_direction_x, .diretion_y = current_direction_y};
                try visited.append(loc);
            } else {
                // We need to turn 90deg 
                // print("Rotating: {}, {}, Current size: {}\n", .{current_x, current_y, visited.items.len});
                // print("Obstacle: {}, {}, {}, {}, {}\n", .{test_x, test_y, isNotObstacle, extraBlock.x != test_x,extraBlock.y != test_y});

                // We were going up
                if(current_direction_x == 0 and current_direction_y == -1) {
                    current_direction_x = 1;
                    current_direction_y = 0;
                }

                // we were going right
                else if(current_direction_x == 1 and current_direction_y == 0) {
                    current_direction_x = 0;
                    current_direction_y = 1;
                }

                // we were going down
                else if(current_direction_x == 0 and current_direction_y == 1) {
                    current_direction_x = -1;
                    current_direction_y = 0;
                }

                // we were going left
                else if(current_direction_x == -1 and current_direction_y == 0) {
                    current_direction_x = 0;
                    current_direction_y = -1;
                }
            }
        }
        return false;
    }

    pub fn find_loops(self: *const Puzzle) !usize {
        var result: usize = 0;
        var path = try self.collect_path();
        
        //We cannot place an obstacle on the starting position;
        _ = path.orderedRemove(0);

        for(path.items) |location| {
            // print("\ntesting: {}, {}\n", .{location.x, location.y});
            if(try self.is_loop(&location)) {
                // print("Found: {}, {}\n", .{location.x, location.y});
                result+=1;
            }
        }

        return result;
    }
};

fn read_input(filename: []const u8) !Puzzle {
    _ = filename;

    var lines = std.mem.splitScalar(u8, data, '\n');

    var row:isize = 0;
    var start_x:isize = 0;
    var start_y:isize = 0;
    const rows = std.mem.count(u8, data, "\n");
    var grid = try allocator.alloc([]bool, rows + 1);

    while(lines.next()) |line| {
        var gridRow = try allocator.alloc(bool, line.len);
        for(line, 0..) |letter, col|  {
            if(letter == '^') {
                start_x = @bitCast(col);
                start_y = row;
                gridRow[col] = true;
            } else if(letter == '.') {
                gridRow[col] = true;
            } else if(letter == '#') {
                gridRow[col] = false;
            } else {
                unreachable;
            }
        }
        grid[@bitCast(row)] = gridRow;
        row +=1;
    }

    return Puzzle{.grid = grid, .start_x = start_x, .start_y = start_y};
}

fn part1(filename: []const u8) !void {
    print("  part1:\n", .{});
    const puzzle = try read_input(filename);
    const result = (try puzzle.collect_path()).items.len;
    print("  Result {}\n", .{result});
}

fn part2(filename: []const u8) !void {
    print("  part2:\n", .{});
    const puzzle = try read_input(filename);
    puzzle.read_puzzle();
    const result = try puzzle.find_loops();
    print("  Result {}\n", .{result});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    const filename = "test.txt";
    try part1(filename);
    try part2(filename);
}
