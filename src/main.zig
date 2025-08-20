const uuiz = @import("uuiz");
const std = @import("std");

pub fn main() !void {
    const uuid = uuiz.v4.new();
    std.debug.print("{X}\n", .{uuid});
}
