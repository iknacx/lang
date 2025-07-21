const std = @import("std");
const Token = @import("Token.zig");

const Lexer = @This();

const State = enum {
    start,

    star,

    number,
    identifier,
};

src: [:0]const u8,
idx: usize = 0,
saved: ?Token,

pub fn new(source: [:0]const u8) Lexer {
    return Lexer{
        .src = source,
        .saved = null,
    };
}

pub fn peek(l: *Lexer) !?Token {
    if (l.saved) |tok| return tok;
    l.saved = try l.next();
    return l.saved;
}

pub fn skip(l: *Lexer) void {
    l.saved = null;
}

pub fn next(l: *Lexer) !?Token {
    if (l.saved) |tok| {
        l.saved = null;
        return tok;
    }

    var tok: Token = undefined;
    var start: usize = l.idx;

    state: switch (State.start) {
        .start => {
            switch (l.src[l.idx]) {
                0 => return null,
                ' ', '\t', '\r', '\n' => {
                    l.idx += 1;
                    start = l.idx;
                    continue :state .start;
                },

                '(' => tok.kind = .lpar,
                ')' => tok.kind = .lpar,

                '+' => tok.kind = .plus,
                '-' => tok.kind = .dash,
                '*' => continue :state .star,

                '/' => tok.kind = .slash,
                '=' => tok.kind = .equal,

                '1'...'9' => continue :state .number,
                'a'...'z', 'A'...'Z', '_' => continue :state .identifier,

                else => return error.UnknownCharacter,
            }

            l.idx += 1;
        },

        .star => {
            l.idx += 1;
            switch (l.src[l.idx]) {
                '*' => {
                    tok.kind = .starstar;
                    l.idx += 1;
                },
                else => tok.kind = .star,
            }
        },

        .number => {
            l.idx += 1;
            switch (l.src[l.idx]) {
                '0'...'9' => continue :state .number,
                else => tok.kind = .number,
            }
        },

        .identifier => {
            l.idx += 1;
            switch (l.src[l.idx]) {
                'a'...'z', 'A'...'Z', '0'...'9', '_' => continue :state .identifier,
                else => tok.kind = .identifier,
            }
        },
    }

    tok.value = l.src[start..l.idx];
    return tok;
}
