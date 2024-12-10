const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

// const data = @embedFile("test.txt");
const data = @embedFile("input.txt");

fn isPossible(result: u64, current: u64, rest: []u64) bool {
    if(rest.len == 0) {
        return result == current;
    }
    return isPossible(result, current * rest[0], rest[1..]) or isPossible(result, current + rest[0], rest[1..]);
    
}

fn isPossible2(result: u64, current: u64, rest: []u64) !bool {
    if(current > result) {
        return false;
    }
    if(rest.len == 0) {
        return result == current;
    }

    const scale = std.math.log10_int(rest[0]) + 1;
    // print("current: {}\n", .{current});
    // print("other: {}\n", .{rest[0]});
    // print("scale: {}\n", .{scale});
    // print("result: {}\n", .{current * scale * 10 + rest[0]});

    return try isPossible2(result, current * try std.math.powi(u64, 10, scale) + rest[0], rest[1..]) or
            try isPossible2(result, current * rest[0], rest[1..]) or 
            try isPossible2(result, current + rest[0], rest[1..]);
    
}
const Equation = struct {
    result: u64,
    items: []u64,

    pub fn printEq(self: *const Equation) void {
         print("{}:", .{self.result});
        for(self.items) |right| {
            print(" {},", .{right});
        }
        print("\x1b[\x08m \n", .{});
    }

};

const Puzzle = struct {
    data: []Equation,

    pub fn printPuzzle(self: *const Puzzle) void {
        for(self.data) |eq| {
            eq.printEq();
        }
    }
};

fn parse() !Puzzle {
    var lines = std.mem.splitScalar(u8, data, '\n');
    var result = ArrayList(Equation).init(allocator);
    
    while(lines.next()) |line| {
        const splitIndex = std.mem.indexOfScalar(u8, line, ':').?;
        
        const left = line[0..splitIndex];
        const leftNum = try std.fmt.parseInt(u64, left, 10);
        
        const right = line[splitIndex+2..];
        var rightList = ArrayList(u64).init(allocator);
        var it = std.mem.splitScalar(u8, right, ' ');
        while(it.next()) |item| {
            const val = try std.fmt.parseInt(u64, item, 10);
            try rightList.append(val);
        }
        const eq = Equation {
            .result = leftNum,
            .items = rightList.items,
        };
        try result.append(eq);
    }

    return Puzzle {
        .data = result.items
    };
}

fn part1() !void {
    print("  part1:\n", .{});
    const p  = try parse();
    // p.printPuzzle();

    var sum: u64 = 0;
    for(p.data) |eq| {
        if(isPossible(eq.result, 0, eq.items)) {
            sum += eq.result;
        }
    }
    print("  Result: {}\n", .{sum});
}

fn part2() !void {
    print("  part2:\n", .{});
    const p  = try parse();
    // p.printPuzzle();

    var sum: u64 = 0;
    for(p.data) |eq| {
        if(try isPossible2(eq.result, 0, eq.items)) {
            // print("  Adding: ", .{});
            // eq.printEq();
            sum += eq.result;
        }
    }
    print("  Result: {}\n", .{sum});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    try part1();
    try part2();
}
