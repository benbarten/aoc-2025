// Since the young Elf was just doing silly patterns, you can find the invalid IDs by looking
// for any ID which is made only of some sequence of digits repeated twice.
// So, 55 (5 twice), 6464 (64 twice), and 123123 (123 twice) would all be invalid IDs.

// None of the numbers have leading zeroes; 0101 isn't an ID at all. (101 is a valid ID that you would ignore.)

// Your job is to find all of the invalid IDs that appear in the given ranges. In the above example:

// 11-22 has two invalid IDs, 11 and 22.
// 95-115 has one invalid ID, 99.
// 998-1012 has one invalid ID, 1010.
// 1188511880-1188511890 has one invalid ID, 1188511885.
// 222220-222224 has one invalid ID, 222222.
// 1698522-1698528 contains no invalid IDs.
// 446443-446449 has one invalid ID, 446446.
// 38593856-38593862 has one invalid ID, 38593859.
// The rest of the ranges contain no invalid IDs.
// Adding up all the invalid IDs in this example produces 1227775554.

// What do you get if you add up all of the invalid IDs?

const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var lines = std.mem.splitScalar(u8, input, ',');

    var sum1: i64 = 0;
    var sum2: i64 = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\n\r");

        var parts = std.mem.splitScalar(u8, trimmed, '-');

        const first = parts.next() orelse return error.InvalidFormat;
        const second = parts.next() orelse return error.InvalidFormat;

        var i: i64 = try std.fmt.parseInt(i64, first, 10);
        const end: i64 = try std.fmt.parseInt(i64, second, 10);

        while (i <= end) : (i += 1) {
            var buf: [20]u8 = undefined;
            const str = try std.fmt.bufPrint(&buf, "{d}", .{i});

            // part 2
            const maxWindowLen = str.len / 2;
            const wStart: usize = 0;
            var wEnd: usize = 1;

            while (wEnd <= maxWindowLen) : (wEnd += 1) {
                const window = str[wStart..wEnd];

                if (str.len % window.len != 0) {
                    continue;
                }

                var nextStart: usize = wStart + window.len;
                var nextEnd: usize = wEnd + window.len;

                var matches: bool = true;

                while (nextEnd <= str.len) {
                    if (!std.mem.eql(u8, window, str[nextStart..nextEnd])) {
                        matches = false;
                        break;
                    }

                    nextStart += window.len;
                    nextEnd += window.len;
                }

                if (matches) {
                    sum2 += i;
                    break;
                }
            }

            // part 1
            if (str.len % 2 != 0) {
                continue;
            }

            const front = str[0..(str.len / 2)];
            const back = str[(str.len / 2)..];

            if (std.mem.eql(u8, front, back)) {
                sum1 += i;
            }
        }
    }

    std.debug.print("Part 1: {d}", .{sum1});
    std.debug.print("Part 2: {d}", .{sum2});
}
