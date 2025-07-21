const std = @import("std");
const Lexer = @import("syntax/Lexer.zig");

pub fn main() !void {
    var l = Lexer.new("a = 31");
    while (try l.next()) |tok| std.log.info("Token({s}) = {s}", .{ @tagName(tok.kind), tok.value });
}
