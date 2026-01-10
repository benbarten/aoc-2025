const std = @import("std");
const input = @embedFile("input.txt");

const point = struct {
    x: usize,
    y: usize,
};
pub fn main() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const start: u8 = 'S';
    const splitter: u8 = '^';

    var grid = std.ArrayList([]const u8){};
    defer grid.deinit(allocator);

    // use a hashmap for the bfs queue
    var visited_bfs = std.AutoHashMap(point, void).init(allocator);
    defer visited_bfs.deinit();

    var q = std.ArrayList(point){};
    defer q.deinit(allocator);

    while (lines.next()) |line| {
        try grid.append(allocator, line);
    }

    var start_point: point = undefined;

    // find the starting point
    for (grid.items[0], 0..) |field, i| {
        if (field == start) {
            start_point = point{ .x = i, .y = 0 };
            try visited_bfs.put(start_point, {});
            try q.append(allocator, start_point);
        }
    }

    var count_part1: i64 = 0;

    var qidx: usize = 0;

    while (qidx < q.items.len) {
        const p = q.items[qidx];
        qidx += 1;

        // this is the last line, we can't proceed
        if (p.y + 1 == grid.items.len) {
            continue;
        }

        const beneath: point = point{ .x = p.x, .y = p.y + 1 };

        // found a splitter
        if (grid.items[beneath.y][beneath.x] == splitter) {
            // first things first, update the count
            count_part1 += 1;

            // new beams start beside the splitter (same row as splitter)
            const left = point{ .x = p.x - 1, .y = p.y + 1 };

            // check if neighbor is in bounds, we haven't added it yet to the q and it's not a splitter
            if (left.x >= 0 and !visited_bfs.contains(left) and grid.items[left.y][left.x] != splitter) {
                try visited_bfs.put(left, {});
                try q.append(allocator, left);
            }

            const right = point{ .x = p.x + 1, .y = p.y + 1 };

            // check if neighbor is in bounds, we haven't added it yet to the q and it's not a splitter
            if (right.x >= 0 and !visited_bfs.contains(right) and grid.items[right.y][right.x] != splitter) {
                try visited_bfs.put(right, {});
                try q.append(allocator, right);
            }
        } else if (!visited_bfs.contains(beneath)) {
            try visited_bfs.put(beneath, {});
            try q.append(allocator, beneath);
        }
    }

    std.debug.print("Part 1: {d}\n", .{count_part1});

    // Part 2: Count all paths to the end using BFS with path counting
    // path_counts stores how many paths reach each point
    var path_counts = std.AutoHashMap(point, i64).init(allocator);
    defer path_counts.deinit();

    var q2 = std.ArrayList(point){};
    defer q2.deinit(allocator);

    try path_counts.put(start_point, 1);
    try q2.append(allocator, start_point);

    var q2idx: usize = 0;
    var count_part2: i64 = 0;

    while (q2idx < q2.items.len) {
        const p = q2.items[q2idx];
        q2idx += 1;

        const current_paths = path_counts.get(p).?;

        // this is the last line, we reached the end
        if (p.y + 1 == grid.items.len) {
            count_part2 += current_paths;
            continue;
        }

        const beneath: point = point{ .x = p.x, .y = p.y + 1 };

        // found a splitter - split into left and right (beside the splitter)
        if (grid.items[beneath.y][beneath.x] == splitter) {
            const left = point{ .x = p.x - 1, .y = p.y + 1 };

            if (left.x < grid.items[left.y].len and grid.items[left.y][left.x] != splitter) {
                const left_entry = try path_counts.getOrPut(left);
                if (!left_entry.found_existing) {
                    left_entry.value_ptr.* = 0;
                    try q2.append(allocator, left);
                }
                left_entry.value_ptr.* += current_paths;
            }

            const right = point{ .x = p.x + 1, .y = p.y + 1 };

            if (right.x < grid.items[right.y].len and grid.items[right.y][right.x] != splitter) {
                const right_entry = try path_counts.getOrPut(right);
                if (!right_entry.found_existing) {
                    right_entry.value_ptr.* = 0;
                    try q2.append(allocator, right);
                }
                right_entry.value_ptr.* += current_paths;
            }
        } else {
            // continue downward
            const beneath_entry = try path_counts.getOrPut(beneath);
            if (!beneath_entry.found_existing) {
                beneath_entry.value_ptr.* = 0;
                try q2.append(allocator, beneath);
            }
            beneath_entry.value_ptr.* += current_paths;
        }
    }

    std.debug.print("Part 2: {d}\n", .{count_part2});
}
