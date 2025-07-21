const Token = @This();

pub const Kind = enum {
    lpar,
    rpar,

    plus,
    dash,

    star,
    starstar,

    slash,
    equal,

    number,
    identifier,
};

kind: Kind,
value: []const u8,
