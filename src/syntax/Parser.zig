const std = @import("std");
const ast = @import("ast.zig");
const Lexer = @import("Lexer.zig");

const Parser = @This();

const OpInfo = struct {
    const Assoc = enum { none, left, right };

    power: usize,
    assoc: Assoc = .none,

    const prefix: std.StaticStringMap(OpInfo) = .initComptime(.{
        .{ "+", OpInfo{ .power = 2 } },
        .{ "-", OpInfo{ .power = 2 } },
    });

    const infix: std.StaticStringMap(OpInfo) = .initComptime(.{
        .{ "+", OpInfo{ .power = 0, .assoc = .left } },
        .{ "-", OpInfo{ .power = 0, .assoc = .left } },
        .{ "*", OpInfo{ .power = 1, .assoc = .left } },
        .{ "/", OpInfo{ .power = 1, .assoc = .left } },
        .{ "**", OpInfo{ .power = 3, .assoc = .right } },
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

    var lhs = try p.allocator.create(ast.Expression);
    errdefer p.allocator.destroy(lhs);

    switch (tok.kind) {
        .identifier, .number => lhs.* = .{ .literal = .{ .value = tok.value } },
        .plus, .dash => {
            const info = OpInfo.prefix.get(tok.value) orelse return error.UnkownOperator;

            lhs.* = .{ .unaryop = .{
                .op = tok.value,
                .expr = try p.expression(info.power + 1),
            } };
        },
        .lpar => {
            lhs = try p.expression(0);
            const rpar = try p.lexer.next() orelse return error.RightParenExpected;
            if (rpar.kind != .rpar) return error.RightParenExpected;
        },
        else => return error.LiteralOrOperatorExpected,
    }

    while (true) {
        tok = try p.lexer.peek() orelse break;
        const op = switch (tok.kind) {
            .plus, .dash, .star, .slash, .starstar => tok.value,
            else => break,
        };

        const info = OpInfo.infix.get(tok.value) orelse return error.UnkownOperator;
        if (info.power < power) break;
        p.lexer.skip();

        const rhs = try p.expression(switch (info.assoc) {
            .left => info.power + 1,
            .right => info.power,
            else => return error.UnexpectedNoneAssoc,
        });

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
