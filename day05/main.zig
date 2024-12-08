const print = @import("std").debug.print;
const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = @import("std").heap.page_allocator;
const HashMap = @import("std").AutoHashMap;

const Puzzle = struct { 
    rules: HashMap(u32, ArrayList(u32)),
    inv_rules: HashMap(u32, ArrayList(u32)),
    pages: ArrayList(ArrayList(u32)), 

    pub fn print_puzzle(self: *const Puzzle) void {
        print("rules: \n", .{});
        var rules = self.rules.iterator();
        while(rules.next()) |entry| {
            const key = entry.key_ptr;
            print("\tentry: {{{d},(", .{key.*});
            for (entry.value_ptr.items) |value| {
                print("{d},", .{value});
            }
            print("\x1b[\x08m)}}\n", .{});
        }
        print("inv_rules: \n", .{});
        var inv_rules = self.inv_rules.iterator();
        while(inv_rules.next()) |entry| {
            const key = entry.key_ptr;
            print("\tentry: {{{d},(", .{key.*});
            for (entry.value_ptr.items) |value| {
                print("{d},", .{value});
            }
            print("\x1b[\x08m)}}\n", .{});
        }
        print("\npages: \n", .{});
        for(self.pages.items) |entry| {
            print("\tentry: (", .{});
            for (entry.items) |value| {
                print("{d},", .{value});
            }
            print("\x1b[\x08m)\n", .{});
        }
        
    }
};

fn read_input(filename: []const u8) !Puzzle {
     var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var rules = HashMap(u32, ArrayList(u32)).init(allocator);
    var pages = ArrayList(ArrayList(u32)).init(allocator);
    
    var buf: [1024]u8 = undefined;
    var stage:i32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // print("reading: \"{s}\"\n", .{line});
        if(line.len == 0) {
            stage = 1;
            continue;
        }

        // reading the rules
        if(stage == 0) {
            const split = std.mem.indexOfScalar(u8, line, '|').?;

            const left = line[0..split];
            const nLeft = try std.fmt.parseInt(u32, left, 10);

            const right = line[(split+1)..];
            const nRight = try std.fmt.parseInt(u32, right, 10);

            var key = try rules.getOrPutValue(nLeft, ArrayList(u32).init(allocator));
            try key.value_ptr.append(nRight);
        } 
        // reading the pages
        else {
            var list = ArrayList(u32).init(allocator);
            var it = std.mem.splitScalar(u8, line, ',');
            while(it.next()) |x| {
                const number = try std.fmt.parseInt(u8, x, 10);
                try list.append(number);
            }
            try pages.append(list);
        }
    }
    var inv = HashMap(u32, ArrayList(u32)).init(allocator);
    var it = rules.iterator();
    while(it.next()) |entry| {
        for(entry.value_ptr.items) |value| {
            var key = try inv.getOrPutValue(value, ArrayList(u32).init(allocator));
            try key.value_ptr.append(entry.key_ptr.*);
        }
    }

    return Puzzle{ .pages = pages, .rules = rules, .inv_rules = inv,};
}

fn correct_line_and_find_middle(line: ArrayList(u32), rules: HashMap(u32, ArrayList(u32))) !u32 {
    var newLine = ArrayList(u32).init(allocator);
    try newLine.append(line.items[0]);
    for(line.items[1..]) |item| {
        print("item: {}\n", .{item});
        var currentSize = newLine.items.len;
        const deps = rules.getPtr(item);

        if(deps == null) {
            try newLine.insert(0, item);
            print("t: {}\n", .{currentSize});
            print("t: {}\n", .{item});
            continue;
        }

        while (currentSize > 0) {
            print("in\n", .{});


            // if I did not found any items up to the currectSize that are in the dependency list, then the current item can be here.
            if (std.mem.indexOfAny(u32, newLine.items[0..currentSize], deps.?.*.items) == null) {
                print("happened\n", .{});
                try newLine.insert(currentSize, item);
                break;
            }
            currentSize-=1;
            if(currentSize == 0) {
                // unreachable;
                try newLine.insert(currentSize, item);
            }
        }
    }

    print("\n!!newLine: (", .{});
    for(newLine.items) |entry| {
        print("{d},", .{entry});
    }
    print("\x1b[\x08m)\n", .{});

    return newLine.items[newLine.items.len/2];
}

fn part1(filename: []const u8) !void {
    print("  part1:\n", .{});
    const puzzle = try read_input(filename);
    // puzzle.print_puzzle();

    var sum: u32 = 0;

    for(puzzle.pages.items) |line| {
        var found = true;
        // print("page: {}\n", .{ii});
        for(line.items, 0..) |page, i| {
            // print("looking up for page: {}\n", .{page});
            const deps = puzzle.rules.getPtr(page);
            if(deps == null) {
                continue;
            }
            // print("found some\n", .{});
            if (std.mem.indexOfAny(u32, line.items[0..i], deps.?.*.items) != null) {
                found = false;
                break;
            }
        }
        if(found) {
            // print("\tcorrect\n", .{});
            sum += line.items[line.items.len / 2];
        }
    }

    print("  Result: {}\n", .{sum});
}

fn part2(filename: []const u8) !void {
    print("  part2:\n", .{});
    const puzzle = try read_input(filename);
    puzzle.print_puzzle();

    var sum: u32 = 0;

    for(puzzle.pages.items) |line| {
        var found = true;
        for(line.items, 0..) |page, i| {
            // print("looking up for page: {}\n", .{page});
            const deps = puzzle.rules.getPtr(page);
            if(deps == null) {
                continue;
            }
            // print("found some\n", .{});
            if (std.mem.indexOfAny(u32, line.items[0..i], deps.?.*.items) != null) {
                found = false;
                break;
            }
        }
        if(!found) {
            
            sum += try correct_line_and_find_middle(line, puzzle.inv_rules);
            // print("\tcorrect: {}\n", .{sum});
        }
    }

    print("  Result: {}\n", .{sum});
}

pub fn main() !void {
    print("Problem 1:\n", .{});
    // const filename = "test.txt";
    const filename = "input.txt";
    try part1(filename);
    try part2(filename);
}
