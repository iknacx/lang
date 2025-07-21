const std = @import("std");
const ast = @import("ast.zig");
const Lexer = @import("Lexer.zig");

const Parser = @This();

const opinfo = struct {
    const prefix: std.StaticStringMap(usize) = .initComptime(.{
        .{ "+", 2 },
        .{ "-", 2 },
    });

    const infix: std.StaticStringMap(usize) = .initComptime(.{
        .{ "+", 0 },
        .{ "-", 0 },
        .{ "*", 1 },
        .{ "/", 1 },
    });
};

lexer: Lexer,
allocator: std.mem.Allocator,

pub fn new(lexer: Lexer, allocator: std.mem.Allocator) Parser {
    return Parser{
        .lexer = lexer,
        .allocator = allocator,
    };
}

pub fn expression(p: *Parser, power: usize) !*ast.Expression {
    var tok = try p.lexer.next() orelse return error.LhsExpected;

    const e = try p.allocator.create(ast.Expression);
    errdefer p.allocator.destroy(e);

    var lhs = switch (tok.kind) {
        .identifier, .number => blk: {
            e.* = .{ .literal = .{ .value = tok.value } };
            break :blk e;
        },
        .plus, .dash => blk: {
            const op_power = opinfo.prefix.get(tok.value) orelse return error.UnkownOperator;

            e.* = .{ .unaryop = .{
                .op = tok.value,
                .expr = try p.expression(op_power + 1),
            } };

            break :blk e;
        },
        else => return error.LiteralOrOperatorExpected,
    };

    while (true) {
        tok = try p.lexer.peek() orelse break;
        const op = switch (tok.kind) {
            .plus, .dash, .star, .slash => tok.value,
            else => break,
        };

        const op_power = opinfo.infix.get(op) orelse return error.UnkownOperator;
        if (op_power < power) break;
        p.lexer.skip();

        const rhs = try p.expression(op_power + 1);

        const tmp = try p.allocator.create(ast.Expression);
        tmp.* = .{ .binaryop = .{
            .op = op,
            .lhs = lhs,
            .rhs = rhs,
        } };

        lhs = tmp;
    }

    return lhs;
}
