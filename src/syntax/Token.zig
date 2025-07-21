const Token = @This();

pub const Kind = enum {
    lpar,
    rpar,

    plus,
    dash,
    star,
    slash,
    equal,

    number,
    identifier,
};

kind: Kind,
value: []const u8,
