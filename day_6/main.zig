const std = @import("std");

const input = @embedFile("input.txt");
pub fn main() !void {
    const op = enum { add, mul };

    const problem = struct {
        numbers: [4]i32,
        op: op,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var problems = std.ArrayList(problem){};
    defer problems.deinit(allocator);

    var lines = std.mem.splitScalar(u8, input, '\n');
    var lc: usize = 0;

    while (lines.next()) |line| {
        var positions = std.mem.splitScalar(u8, line, ' ');

        var i: usize = 0;

        while (positions.next()) |position| {
            if (position.len == 0 or std.mem.eql(u8, position, &[_]u8{' '})) {
                continue;
            }

            switch (lc) {
                0 => {
                    // parse string to int
                    const a = std.fmt.parseInt(i32, position, 10) catch |err| {
                        std.debug.print("Failed to parse number a: {}\n", .{err});
                        return err;
                    };

                    try problems.append(allocator, problem{ .numbers = [4]i32{ a, 0, 0, 0 }, .op = op.add });
                },
                1 => {
                    const b = std.fmt.parseInt(i32, position, 10) catch |err| {
                        std.debug.print("Failed to parse number b: {}\n", .{err});
                        return err;
                    };

                    problems.items[i].numbers[1] = b;
                },
                2 => {
                    const c = std.fmt.parseInt(i32, position, 10) catch |err| {
                        std.debug.print("Failed to parse number c: {}\n", .{err});
                        return err;
                    };

                    problems.items[i].numbers[2] = c;
                },
                3 => {
                    const d = std.fmt.parseInt(i32, position, 10) catch |err| {
                        std.debug.print("Failed to parse number d: {}\n", .{err});
                        return err;
                    };

                    problems.items[i].numbers[3] = d;
                },
                4 => {
                    const parsed_op = switch (position[0]) {
                        '+' => op.add,
                        '*' => op.mul,
                        else => {
                            std.debug.print("Invalid operator: {s}\n", .{position});
                            std.debug.print("Problem: {any}\n", .{problems.items[i]});
                            return error.InvalidOperator;
                        },
                    };

                    problems.items[i].op = parsed_op;
                },
                else => {
                    return error.InvalidOperation;
                },
            }

            i += 1;
        }

        lc += 1;
    }

    var total_sum: i64 = 0;

    for (problems.items) |prob| {
        switch (prob.op) {
            op.add => {
                var result: i64 = 0;
                for (prob.numbers) |num| {
                    result += num;
                }

                total_sum += result;
            },
            op.mul => {
                var result: i64 = 1;
                for (prob.numbers) |num| {
                    result *= num;
                }

                total_sum += result;
            },
        }
    }

    std.debug.print("Part 1: {d}\n", .{total_sum});

    // Part 2: Read columns right-to-left
    // Each column is a number (digits top-to-bottom), space columns separate problems

    // Collect all lines and find max length
    var all_lines = std.ArrayList([]const u8){};
    defer all_lines.deinit(allocator);

    var max_len: usize = 0;
    var lines2 = std.mem.splitScalar(u8, input, '\n');
    while (lines2.next()) |line| {
        if (line.len == 0) continue;
        if (line.len > max_len) max_len = line.len;
        try all_lines.append(allocator, line);
    }

    if (all_lines.items.len == 0) return;

    const num_rows = all_lines.items.len;
    const operator_row = num_rows - 1;

    // Process columns right to left
    var current_numbers = std.ArrayList(i64){};
    defer current_numbers.deinit(allocator);
    var current_op: op = .add;
    var total_sum2: i64 = 0;
    var in_problem = false;

    var col_idx: usize = max_len;
    while (col_idx > 0) {
        col_idx -= 1;

        // Check if this column is all spaces (separator)
        var is_separator = true;
        for (all_lines.items) |line| {
            if (col_idx < line.len and line[col_idx] != ' ') {
                is_separator = false;
                break;
            }
        }

        if (is_separator) {
            // End of current problem (if we were in one)
            if (in_problem and current_numbers.items.len > 0) {
                const result: i64 = switch (current_op) {
                    .add => blk: {
                        var sum: i64 = 0;
                        for (current_numbers.items) |n| sum += n;
                        break :blk sum;
                    },
                    .mul => blk: {
                        var prod: i64 = 1;
                        for (current_numbers.items) |n| prod *= n;
                        break :blk prod;
                    },
                };
                total_sum2 += result;
                current_numbers.clearRetainingCapacity();
                current_op = .add;
            }
            in_problem = false;
        } else {
            in_problem = true;

            // Read this column: digits from rows 0..(n-2), operator from row n-1
            var num: i64 = 0;
            for (all_lines.items, 0..) |line, row| {
                if (col_idx >= line.len) continue;
                const c = line[col_idx];

                if (row == operator_row) {
                    // Check for operator
                    if (c == '+') current_op = .add else if (c == '*') current_op = .mul;
                } else {
                    // Digit row - build number top-to-bottom
                    if (c >= '0' and c <= '9') {
                        num = num * 10 + (c - '0');
                    }
                }
            }

            try current_numbers.append(allocator, num);
        }
    }

    // Handle the last problem (leftmost)
    if (current_numbers.items.len > 0) {
        const result: i64 = switch (current_op) {
            .add => blk: {
                var sum: i64 = 0;
                for (current_numbers.items) |n| sum += n;
                break :blk sum;
            },
            .mul => blk: {
                var prod: i64 = 1;
                for (current_numbers.items) |n| prod *= n;
                break :blk prod;
            },
        };
        total_sum2 += result;
    }

    std.debug.print("Part 2: {d}\n", .{total_sum2});
}
