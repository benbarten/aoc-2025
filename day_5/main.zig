const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const range = struct {
        start: i64,
        end: i64,
    };

    var ranges = std.ArrayList(range){};
    defer ranges.deinit(allocator);

    var nums = std.ArrayList(i64){};
    defer nums.deinit(allocator);

    var process_ranges = true;

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            process_ranges = false;
            continue;
        }

        if (process_ranges) {
            var parts = std.mem.splitScalar(u8, line, '-');
            const start = parts.next() orelse return error.InvalidFormat;
            const end = parts.next() orelse return error.InvalidFormat;

            const start_num = std.fmt.parseInt(i64, start, 10) catch |err| {
                std.debug.print("Failed to parse range start: {}\n", .{err});
                return err;
            };

            const end_num = std.fmt.parseInt(i64, end, 10) catch |err| {
                std.debug.print("Failed to parse range end: {}\n", .{err});
                return err;
            };

            try ranges.append(allocator, range{ .start = start_num, .end = end_num });
        } else {
            const num: i64 = std.fmt.parseInt(i64, line, 10) catch |err| {
                std.debug.print("Failed to parse number: {}\n", .{err});
                return err;
            };

            try nums.append(allocator, num);
        }
    }

    // sort ranges by start
    std.mem.sort(range, ranges.items, {}, struct {
        fn lessThan(_: void, a: range, b: range) bool {
            return a.start < b.start;
        }
    }.lessThan);

    // sort numbers
    std.mem.sort(i64, nums.items, {}, comptime std.sort.asc(i64));

    // join ranges
    var joined_ranges = std.ArrayList(range){};
    defer joined_ranges.deinit(allocator);

    var i: usize = 1;
    var last: range = ranges.items[0];

    while (i < ranges.items.len) {
        const current = ranges.items[i];

        if (current.start <= last.end) { // we have an overlap
            // set new end
            if (current.end > last.end) {
                last.end = current.end;
            }
        } else { // no overlap
            try joined_ranges.append(allocator, last);
            last = current;
        }

        i += 1;
    }

    // don't forget the last one
    try joined_ranges.append(allocator, last);

    // iterate over ranges and numbers with two pointers
    var ri: usize = 0;
    var ni: usize = 0;

    var count: i64 = 0;

    while (ni < nums.items.len) {
        const current_num = nums.items[ni];
        while (ri < ranges.items.len) {
            const current_range = ranges.items[ri];

            // num after current range, go to next range
            if (current_num > current_range.end) {
                ri += 1;
                continue;
            }

            // num within range,
            if (current_num >= current_range.start and current_num <= current_range.end) {
                count += 1;
            }

            ni += 1;
            break;
        }

        if (ri >= ranges.items.len) {
            break;
        }
    }

    std.debug.print("Part 1: {d}\n", .{count});

    var count2: i64 = 0;
    for (joined_ranges.items) |r| {
        count2 += r.end - r.start + 1;
    }

    std.debug.print("Part 2: {d}\n", .{count2});
}
