const std = @import("std");
const input = @embedFile("input.txt");

pub fn maxJoltage(line: []const u8, banks: comptime_int) !i64 {
    var digits: [banks]u8 = undefined;
    var start: usize = 0;

    for (0..banks) |idx| {
        for (line[start + 1 .. line.len - banks + idx + 1], start + 1..line.len - banks + idx + 1) |item, i| {
            if (item > line[start]) {
                start = i;
            }
        }

        digits[idx] = line[start];
        start += 1;
    }

    return std.fmt.parseInt(i64, digits[0..banks], 10) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        std.debug.print("Line: {s}\n", .{line});
        std.debug.print("Digits: {s}\n", .{digits[0..banks]});
        return err;
    };
}

pub fn main() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');

    const banks1 = 2;
    const banks2 = 12;

    var sum1: i64 = 0;
    var sum2: i64 = 0;

    while (lines.next()) |line| {
        sum1 += try maxJoltage(line, banks1);
        sum2 += try maxJoltage(line, banks2);
    }

    std.debug.print("Part 1: {d}\n", .{sum1});
    std.debug.print("Part 2: {d}\n", .{sum2});
}
