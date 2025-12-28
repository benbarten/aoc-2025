const input = @embedFile("input.txt");
const std = @import("std");

pub fn main() !void {
    var lines = std.mem.splitScalar(u8, input, '\n');

    var dial: i32 = 50;
    var count1: i32 = 0;
    var count2: i32 = 0;

    while (lines.next()) |line| {
        const direction = line[0];
        const steps: i32 = std.fmt.parseInt(i32, line[1..], 10) catch |err| {
            std.debug.print("Parsing number failed: '{}'\n", .{err});
            return err;
        };

        switch (direction) {
            'R' => {
                const sum: i32 = dial + steps;
                dial = @mod(sum, 100);
                count2 += @intCast(@abs(@divFloor(sum, 100)));
            },
            'L' => {
                const sum: i32 = dial - steps;
                const start = dial;
                dial = @mod(sum + 100, 100);

                if (sum > 0) {
                    continue;
                }

                if (sum == 0) {
                    count1 += 1;
                    count2 += 1;
                    continue;
                }

                count2 += @intCast(@abs(sum) / 100);

                // unless we start from 0, we must have crossed it
                if (start != 0) {
                    count2 += 1;
                }
            },
            else => {
                std.debug.print("Parsing direction failed: '{}'\n", .{direction});
                return error.InvalidCharacter;
            },
        }

        if (dial == 0) {
            count1 += 1;
        }
    }

    std.debug.print("Part 1: {d}\n", .{count1});
    std.debug.print("Part 2: {d}\n", .{count2});
}
