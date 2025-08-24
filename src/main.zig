const uuiz = @import("uuiz");
const std = @import("std");

pub fn main() !void {
    // const uuid = uuiz.v4.new();
    // std.debug.print("{X}\n", .{uuid});

    var g = uuiz.v1.init();
    const id = g.new();
    const v = try uuiz.core.version(id);
    std.debug.print("{X}\n", .{id});
    std.debug.print("{s}\n", .{@tagName(v)});

}
