const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;

const Puzzle = struct {
    rows: usize,
    cols: usize,
    data: [][]u8,

    pub fn print_grid(self: *const Puzzle) void {
        for (self.data) |row| {
            for (row) |cell| {
                print("{c}", .{cell});
            }
            print("\n", .{});
        }
    }
};

fn read_input(filename: []const u8) !Puzzle {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var grid = ArrayList([]u8).init(allocator);
    defer grid.deinit();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // print("reading: {s}\n", .{line});
        const size = line.len;
        const mem = try allocator.alloc(u8, size);
        std.mem.copyForwards(u8, mem, line);
        try grid.append(mem);
    }
    const cols = grid.items[0].len;
    const rows = grid.items.len;
    const b = try grid.toOwnedSlice();
    return Puzzle{ .cols = cols, .rows = rows, .data = b };
}

fn find_xmas(grid: [][]u8, rows: usize, cols: usize, start_row: usize, start_col: usize, direction_x: isize, direction_y: isize) bool {
    if (grid[start_row][start_col] != 'X') {
        return false;
    }
    var found_M = false;
    var found_A = false;
    var found_S = false;

    var n_row: isize = @bitCast(start_row);
    var n_col: isize = @bitCast(start_col);
    // print("\nstart_row: {}\n", .{start_row});
    // print("start_col: {}\n", .{start_col});
    while (true) {
        if(found_M and found_A and found_S) {
            break;
        }
        // print("state:: found_M: {}, found_A: {}, found_S {}\n", .{ found_M, found_A, found_S });
        n_row += direction_y;
        n_col += direction_x;
        // print("n_row: {}\n", .{n_row});
        // print("n_col: {}\n", .{n_col});

        // If I am out of bounds then we cannot find the word no more
        if (n_row >= rows or n_col >= cols or n_row < 0 or n_col < 0) {
            // print("out of bounds\n", .{});
            return false;
        }

        const c = grid[@bitCast(n_row)][@bitCast(n_col)];
        // print("c: {c}\n", .{c});
        if (c == 'X') {
            // print("Unxpected 'X'\n", .{});
            return false;
        }

        if (c == 'M' and found_M) {
            // print("Unxpected 'M'\n", .{});
            return false;
        }
        if (c == 'A' and (found_A or !found_M)) {
            // print("Unxpected 'A'\n", .{});
            return false;
        }
        if (c == 'S' and (found_S or !found_M or !found_A)) {
            // print("Unxpected 'S'\n", .{});
            return false;
        }

        if (c == 'M' and found_M == false and found_A == false and found_S == false) {
            // print("M\n", .{});
            found_M = true;
            continue;
        }
        if (c == 'A' and found_M and found_A == false and found_S == false) {
            // print("A\n", .{});
            found_A = true;
            continue;
        }
        if (c == 'S' and found_M and found_A and found_S == false) {
            // print("S\n", .{});
            found_S = true;
            continue;
        }
    }
    // print("Escaped:: found_M: {}, found_A: {}, found_S {}\n", .{ found_M, found_A, found_S });
    return true;
}

fn part1(filename: []const u8) !void {
    print("  part1:\n", .{});
    const puzzle = try read_input(filename);
    // puzzle.print_grid();
    var sum: u32 = 0;
    for (0..puzzle.rows) |x| {
        for (0..puzzle.cols) |y| {

            // Search Forwards
            if (find_xmas(puzzle.data, puzzle.rows, puzzle.cols, x, y, 1, 0)) {
                // print("!!!!Found Search Forwards at {},{}\n", .{ x,y });
                sum += 1;
            }

            // Search Downwards
            if (find_xmas(puzzle.data, puzzle.rows, puzzle.cols, x, y, 0, 1)) {
                // print("!!!!Found Search Downwards at {},{}\n", .{ x,y });
                sum += 1;
            }

            // Search Backwards
            if (find_xmas(puzzle.data, puzzle.rows, puzzle.cols, x, y, -1, 0)) {
                // print("!!!!Found Search Backwards at {},{}\n", .{ x,y });
                sum += 1;
            }

            // Search Upwards
            if (find_xmas(puzzle.data, puzzle.rows, puzzle.cols, x, y, 0, -1)) {
                // print("!!!!Found Search Upwards at {},{}\n", .{ x,y });
                sum += 1;
            }

            // Search Diagnonal
            if (find_xmas(puzzle.data, puzzle.rows, puzzle.cols, x, y, 1, 1)) {
                // print("!!!!Found Search Diagnonal at {},{}\n", .{ x,y });
                sum += 1;
            }

            // Search Diagnonal reverse
            if (find_xmas(puzzle.data, puzzle.rows, puzzle.cols, x, y, -1, -1)) {
                // print("!!!!Found Search Diagnonal reverse at {},{}\n", .{ x,y });
                sum += 1;
            }

            // Search Diagnonal 2
            if (find_xmas(puzzle.data, puzzle.rows, puzzle.cols, x, y, 1, -1)) {
                // print("!!!!Found Search Diagnonal 2 at {},{}\n", .{ x,y });
                sum += 1;
            }

            // Search Diagnonal reverse 2
            if (find_xmas(puzzle.data, puzzle.rows, puzzle.cols, x, y, -1, 1)) {
                // print("!!!!Found Search Diagnonal reverse 2 at {},{}\n", .{ x,y });
                sum += 1;
            }
        }
    }

    print("  Reuslt: {d}\n", .{sum});
}

fn found_mas(grid: [][]u8, base_row: usize, base_col:usize) bool{
    const w1:[3]u8 = .{grid[base_row-1][base_col-1],grid[base_row][base_col],grid[base_row+1][base_col+1]};
    const w2:[3]u8 = .{grid[base_row+1][base_col-1],grid[base_row][base_col],grid[base_row-1][base_col+1]};

    const w1_correct = std.mem.eql(u8, &w1, "MAS") or std.mem.eql(u8, &w1, "SAM");
    const w2_correct = std.mem.eql(u8, &w2, "MAS") or std.mem.eql(u8, &w2, "SAM");
    // print("Word 1: {s} correct: {}\n", .{w1, w1_correct});
    // print("Word 2: {s} correct: {}\n", .{w2, w2_correct});
    return w1_correct and w2_correct;
}

fn part2(filename: []const u8) !void {
    print("  part2:\n", .{});
    const puzzle = try read_input(filename);
    // puzzle.print_grid();
    var sum: u32 = 0;
    for (1..(puzzle.rows-1)) |row| {
        for (1..(puzzle.cols-1)) |col| {
            // print("Testing on {},{}\n", .{row,col});
            if(found_mas(puzzle.data, row,col)) {
                sum += 1;
            }
        }
    }

    print("  Reuslt: {d}\n", .{sum});

}

pub fn main() !void {
    print("Problem 1:\n", .{});
    const filename = "input.txt";
    try part1(filename);
    try part2(filename);
}
