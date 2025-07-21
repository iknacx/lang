const std = @import("std");
const Lexer = @import("syntax/Lexer.zig");

pub fn main() !void {
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
        var l = Lexer.new(buffer[0..len :0]);
        while (try l.next()) |tok| std.debug.print("Token({s}): {s}\n", .{ @tagName(tok.kind), tok.value });
    }
}
