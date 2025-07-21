const std = @import("std");
const Lexer = @import("syntax/Lexer.zig");
const Parser = @import("syntax/Parser.zig");

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
        expr.debug();
        std.debug.print("\n", .{});
    }
}
