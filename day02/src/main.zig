const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const Puzzle = struct { data: ArrayList(ArrayList(i32)) };

fn read_input(filename: []const u8) Puzzle {
    var file = std.fs.cwd().openFile(filename, .{}) catch {
        unreachable;
    };
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var puzzle: Puzzle = .{ .data = ArrayList(ArrayList(i32)).init(allocator) };

    var buf: [1024]u8 = undefined;
    while (in_stream.readUntilDelimiterOrEof(&buf, '\n') catch {
        unreachable;
    }) |line| {
        var it = std.mem.splitSequence(u8, line, " ");
        var current = ArrayList(i32).init(allocator);
        while (it.next()) |nText| {
            const number = std.fmt.parseInt(i32, nText, 10) catch {
                unreachable;
            };
            current.append(number) catch {
                unreachable;
            };
        }
        puzzle.data.append(current) catch {
            unreachable;
        };
    }

    return puzzle;
}

fn test_row(row: []i32) bool {
    const step = row[0] - row[1];
    const positive = step > 0;
    // print("nPositive: {}, nStep: {}\n", .{ positive, step });

    if (@abs(step) > 3 or @abs(step) < 1) {
        return false;
    }

    for (row[2..], 2..) |item, index| {
        const nStep = row[index - 1] - item;
        const nPositive = nStep > 0;
        // print("nPositive: {}, nStep: {}\n", .{ nPositive, nStep });
        if (@abs(nStep) > 3 or @abs(nStep) < 1 or nPositive != positive) {
            return false;
        }
    }
    return true;
}

fn part1(input: []const u8) !void {
    print("  part1: ", .{});
    const puzzle = read_input(input);

    var sum: i32 = 0;
    for (puzzle.data.items) |row| {
        if (test_row(row.items)) {
            sum += 1;
        }
    }
    print("{}\n", .{sum});
}

fn Skipper(comptime dataType: type) type {
    return struct {
        data: []dataType,
        skipIndex: u32,
        count: usize,

        fn start(items: []dataType, legth: usize, skipIndex: u32) Skipper(dataType) {
            return .{
                .data = items,
                .skipIndex = skipIndex,
                .count = legth,
            };
        }

        fn skip(self: *Skipper(dataType)) ![]dataType {
            var result = comptime ArrayList(dataType).init(allocator);
            for (0..self.count) |i| {
                if (i == self.skipIndex) {
                    continue;
                }
                try result.append(self.data[i]);
            }
            return result.items;
        }
    };
}

fn part2(input: []const u8) !void {
    print("  part2: ", .{});
    const puzzle = read_input(input);
    var sum: i32 = 0;
    outer: for (puzzle.data.items) |row| {
        if (test_row(row.items)) {
            sum += 1;
        } else {
            // try to remove 1 item to see if it fixs the issue
            for (0..row.items.len) |i| {
                var it = (comptime Skipper(i32)).start(row.items, row.items.len, @truncate(i));
                const skiped = try it.skip();
                // if the row is ok without this item then we are good
                if (test_row(skiped)) {
                    sum += 1;
                    continue :outer;
                }
            }
        }
    }
    print("{}\n", .{sum});
}

pub fn main() !void {
    const input = "input.txt";
    print("Problem 1:\n", .{});
    try part1(input);
    try part2(input);
}
