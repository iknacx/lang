const std = @import("std");

pub const Expression = union(enum) {
    literal: Literal,
    unaryop: UnaryOp,
    binaryop: BinaryOp,

    pub fn debug(e: Expression) void {
        switch (e) {
            .literal => |l| std.debug.print(" {s}", .{l.value}),
            .unaryop => |u| {
                std.debug.print(" ({s}", .{u.op});
                u.expr.debug();
                std.debug.print(")", .{});
            },

            .binaryop => |b| {
                std.debug.print(" ({s}", .{b.op});
                b.lhs.debug();
                b.rhs.debug();
                std.debug.print(")", .{});
            },
        }
    }
};

pub const UnaryOp = struct {
    op: []const u8,
    expr: *Expression,
};

pub const BinaryOp = struct {
    op: []const u8,
    lhs: *Expression,
    rhs: *Expression,
};

pub const Literal = struct {
    value: []const u8,
};
