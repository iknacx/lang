const std = @import("std");
const ast = @import("syntax/ast.zig");
const Lexer = @import("syntax/Lexer.zig");
const Parser = @import("syntax/Parser.zig");

fn eval(root: *ast.Expression) !i64 {
    return switch (root.*) {
        .literal => |lit| try std.fmt.parseInt(i64, lit.value, 10),
        .unaryop => |un| blk: {
            if (std.mem.eql(u8, un.op, "-")) {
                break :blk -(try eval(un.expr));
            } else @panic("TODO");
        },
        .binaryop => |bin| blk: {
            const lhs = try eval(bin.lhs);
            const rhs = try eval(bin.rhs);

            if (std.mem.eql(u8, bin.op, "+")) {
                break :blk lhs + rhs;
            } else if (std.mem.eql(u8, bin.op, "-")) {
                break :blk lhs - rhs;
            } else if (std.mem.eql(u8, bin.op, "*")) {
                break :blk lhs * rhs;
            } else if (std.mem.eql(u8, bin.op, "/")) {
                break :blk @divFloor(lhs, rhs);
            } else @panic("TODO");
        },
    };
}

pub fn main() !void {
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const stdin: std.fs.File = .stdin();
    const stdout: std.fs.File = .stdout();

    var buffer: [64:0]u8 = @splat(0);

    while (true) {
        try stdout.writeAll(">> ");

        const len = try stdin.read(&buffer) -| 1;

        if (len == 0) continue;
        if (len == 1 and buffer[0] == 'q') break;

        // fix sentinel
        buffer[len] = 0;
        const l = Lexer.new(buffer[0..len :0]);
        var p = Parser.new(l, arena.allocator());
        const expr = try p.expression(0);

        const res = try eval(expr);
        std.debug.print("{d}\n", .{res});
    }
}
