const std = @import("std");

pub const Expression = union(enum) {
    literal: Literal,
    binaryop: BinaryOp,

    pub fn debug(e: Expression) void {
        switch (e) {
            .literal => |l| std.debug.print(" {s}", .{l.value}),
            .binaryop => |b| {
                std.debug.print(" ({s}", .{b.op});
                b.lhs.debug();
                b.rhs.debug();
                std.debug.print(")", .{});
            },
        }
    }
};

pub const BinaryOp = struct {
    op: []const u8,
    lhs: *Expression,
    rhs: *Expression,
};

pub const Literal = struct {
    value: []const u8,
};
