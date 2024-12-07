const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;

const Puzzle = struct {
    data: []const u8,
    size: usize,
    index: usize,
    enabled: bool = true,

    fn get_number(self: *Puzzle) ?u8 {
        const c = self.data[self.index];
        // print("\tc: {c}\n", .{c});

        if (c >= '0' and c <= '9') {
            self.index += 1;
            return c;
        }

        return null;
    }

    fn get_num(self: *Puzzle) ?u32 {
        var result: u32 = 0;

        var n = self.get_number();
        // print("\tn1: {}\n", .{n == null});
        if (n == null) {
            return null;
        }
        result = result * 10 + (n.? - '0');

        n = self.get_number();
        // print("\tn2: {}\n", .{n == null});
        if (n == null) {
            const cc = self.data[self.index];
            // print("\tcc: {c}\n", .{cc});
            if (cc == ',' or cc == ')') {
                return result;
            } else {
                return null;
            }
        }
        result = result * 10 + (n.? - '0');

        n = self.get_number();
        // print("\tn3: {}\n", .{n == null});
        if (n == null) {
            const cc = self.data[self.index];
            // print("\tcc: {c}\n", .{cc});
            if (cc == ',' or cc == ')') {
                return result;
            } else {
                return null;
            }
        }
        result = result * 10 + (n.? - '0');

        return result;
    }

    // Starting from the current index move it up to the end of a valid `mul` word
    fn get_mull(self: *Puzzle) bool {
        // print("get_mull\n", .{});
        while (true) {
            if (self.index >= self.size) {
                // print("self.index >= self.size\n", .{});
                return false;
            }

            // In order to get a `mul` word we need at least 3 characters left in the buffer.
            if (self.index + 2 >= self.size) {
                // print("self.index + 2 >= self.size\n", .{});
                // print("index: {}\n", .{self.index});
                // print("size: {}\n", .{self.size});
                return false;
            }

            // print("found valid character {c}.\n", .{self.data[self.index]});

            // if we found the `mul` word we can move the index forward and return `true`.
            if (std.mem.eql(u8, self.data[self.index..(self.index + 3)], "mul")) {
                // print("found valid mul.\n", .{});
                self.index += 3;
                return true;
            }

            if (self.dont()) {
                if (!self.do()) {
                    return false;
                }
            }

            // Other wise we move to the next character and try again.
            self.index += 1;
        }
    }

    // Get the next valid mul result
    pub fn get(self: *Puzzle) ?u32 {
        if (self.index >= self.size) {
            return null;
        }

        while (self.get_mull()) {
            const c = self.data[self.index];

            if (c != '(') {
                self.index += 1;
                continue;
            }
            self.index += 1;

            const n1 = self.get_num();
            // print("n1: {}\n", .{n1 == null});
            if (n1 == null) {
                continue;
            }

            const comma = self.data[self.index];
            if (comma != ',') {
                self.index += 1;
                continue;
            }
            self.index += 1;

            const n2 = self.get_num();
            // print("n2: {}\n", .{n1 == null});
            if (n2 == null) {
                continue;
            }

            const closingParen = self.data[self.index];
            if (closingParen != ')') {
                self.index += 1;
                continue;
            }
            self.index += 1;

            return n1.? * n2.?;
        }

        return null;
    }

    fn do(self: *Puzzle) bool {
        // print("do\n", .{});
        if (self.index >= self.size) {
            return false;
        }

        if (self.enabled) {
            return true;
        }

        // if disabled move forward until you are enabled.
        while (!self.enabled) {

            // No enough space for a do operation
            if (self.index + 4 >= self.size) {
                return false;
            }

            const word = self.data[self.index..(self.index + 4)];
            // print("do, word: {s}\n", .{word});
            if (std.mem.eql(u8, word, "do()")) {
                print("do\n", .{});
                self.enabled = true;
                self.index += 1;
                return true;
            }

            self.index += 1;
        }

        return self.enabled;
    }

    // is the next word don't.
    fn dont(self: *Puzzle) bool {
        // print("dont\n", .{});
        if (self.index + 5 > self.size) {
            return false;
        }
        const word = self.data[self.index..(self.index + 7)];
        // print("dont, word: {s}\n", .{word});
        if (std.mem.eql(u8, word, "don't()")) {
            print("dont\n", .{});
            self.enabled = false;
            return true;
        }

        return false;
    }

    // Get the next valid result with support for do, don't
    pub fn advanced_get(self: *Puzzle) ?u32 {
        if (!self.do()) {
            return null;
        }

        while (true) {

            // My eyes are hearting
            if (self.dont()) {
                if (!self.do()) {
                    break;
                }
            }

            // print("next c: {c}\n", .{self.data[self.index]});
            if (!self.get_mull()) {
                break;
            }

            const c = self.data[self.index];
            // print("next c after mul: {c}\n", .{c});

            if (c != '(') {
                self.index += 1;
                continue;
            }
            self.index += 1;

            const n1 = self.get_num();
            // print("n1: {}\n", .{n1 == null});
            if (n1 == null) {
                continue;
            }

            const comma = self.data[self.index];
            if (comma != ',') {
                self.index += 1;
                continue;
            }
            self.index += 1;

            const n2 = self.get_num();
            // print("n2: {}\n", .{n1 == null});
            if (n2 == null) {
                continue;
            }

            const closingParen = self.data[self.index];
            if (closingParen != ')') {
                self.index += 1;
                continue;
            }
            self.index += 1;

            return n1.? * n2.?;
        }

        return null;
    }
};

fn read_input(filename: []const u8) !Puzzle {
    var file = std.fs.cwd().openFile(filename, .{}) catch {
        unreachable;
    };
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    const size = (try file.stat()).size;

    const contents = try in_stream.readAllAlloc(allocator, size);
    // print("size: {}\n", .{size});
    const puzzle: Puzzle = .{ .data = contents, .index = 0, .size = size };

    return puzzle;
}

const Parser = struct {};

fn part1(filename: []const u8) !void {
    print("  part1:\n", .{});

    var puzzle = try read_input(filename);

    var sum: u32 = 0;
    while (true) {
        const b = puzzle.get();

        if (b == null) {
            break;
        }
        sum += b.?;
    }
    print("\tResult: {d}\n", .{sum});
}

fn part2(filename: []const u8) !void {
    print("  part2:\n", .{});

    var puzzle = try read_input(filename);

    var sum: u32 = 0;
    while (true) {
        const b = puzzle.advanced_get();

        if (b == null) {
            break;
        }
        sum += b.?;
    }
    print("\tResult: {d}\n", .{sum});
}

pub fn main() !void {
    const filename = "input.txt";

    print("Problem 3:\n", .{});
    try part1(filename);
    try part2(filename);
}
