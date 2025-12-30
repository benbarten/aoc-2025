const std = @import("std");
const input = @embedFile("input.txt");

const Point = struct { x: i32, y: i32 };

const directions = [8]Point{
    .{ .x = -1, .y = -1 },
    .{ .x = 0, .y = -1 },
    .{ .x = 1, .y = -1 },
    .{ .x = 1, .y = 0 },
    .{ .x = 1, .y = 1 },
    .{ .x = 0, .y = 1 },
    .{ .x = -1, .y = 1 },
    .{ .x = -1, .y = 0 },
};

pub fn main() !void {
    // we could find out the line length at compile time, but I want to try out ArrayList here...
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var grid = std.ArrayList([]const u8){};
    defer grid.deinit(allocator);

    var lines = std.mem.splitScalar(u8, input, '\n');
    const line_length: usize = lines.peek().?.len;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        try grid.append(allocator, line);
    }

    // part 1

    var total_count: i32 = 0;

    for (0..grid.items.len) |y| {
        for (0..line_length) |x| {
            const current = Point{ .x = @intCast(x), .y = @intCast(y) };

            if (grid.items[@intCast(current.y)][@intCast(current.x)] != '@') {
                continue;
            }

            var count: u8 = 0;

            for (directions) |dir| {
                const cmp = Point{
                    .x = current.x + dir.x,
                    .y = current.y + dir.y,
                };

                // out of bounds
                if (cmp.x < 0 or cmp.x >= line_length or cmp.y < 0 or cmp.y >= grid.items.len) {
                    continue;
                }

                if (grid.items[@intCast(cmp.y)][@intCast(cmp.x)] == '@') {
                    count += 1;
                }
            }

            if (count < 4) {
                total_count += 1;
            }
        }
    }

    std.debug.print("Part 1: {d}\n", .{total_count});

    // part 2

    // initialize a hashmap to store the paper rolls positions that have been removed
    var removed = std.AutoHashMap(Point, void).init(allocator);
    defer removed.deinit();

    var traverse: bool = true;

    while (traverse) {
        traverse = false;

        var removed_current = std.ArrayList(Point){};
        defer removed_current.deinit(allocator);

        for (0..grid.items.len) |y| {
            for (0..line_length) |x| {
                const current = Point{ .x = @intCast(x), .y = @intCast(y) };

                if (grid.items[@intCast(current.y)][@intCast(current.x)] != '@' or removed.contains(current)) {
                    continue;
                }

                var count: u8 = 0;

                for (directions) |dir| {
                    const cmp = Point{
                        .x = current.x + dir.x,
                        .y = current.y + dir.y,
                    };

                    // out of bounds
                    if (cmp.x < 0 or cmp.x >= line_length or cmp.y < 0 or cmp.y >= grid.items.len) {
                        continue;
                    }

                    // has been removed previously
                    if (removed.contains(cmp)) {
                        continue;
                    }

                    if (grid.items[@intCast(cmp.y)][@intCast(cmp.x)] == '@') { // found a roll of paper
                        count += 1;
                    }
                }

                if (count < 4) {
                    try removed_current.append(allocator, current);
                    traverse = true;
                }
            }
        }

        for (removed_current.items) |pr| {
            try removed.put(pr, undefined);
        }
    }

    std.debug.print("Part 2: {d}\n", .{removed.count()});
}
