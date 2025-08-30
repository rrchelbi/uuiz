const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const Md5 = std.crypto.hash.Md5;

const lib = @import("root.zig");
const UUID = lib.UUID;

namespace: UUID,
context: Md5,

const Self = @This();

pub fn init(namespace: UUID) Self {
    var context = Md5.init(.{});
    const namespace_bytes = lib.stringify(namespace);
    context.update(&namespace_bytes);
    return .{
        .namespace = namespace,
        .context = context,
    };
}

pub fn new(self: *Self, name: []const u8) UUID {
    var hash: [16]u8 = undefined;

    self.context.update(name);
    self.context.final(&hash);

    const hash_bits = mem.readInt(u128, &hash, .big);

    const md5_high = @as(u48, @truncate(hash_bits >> 80));
    const md5_mid_and_vers = (@as(u16, @truncate(hash_bits >> 64)) & 0x0FFF) | 0x3000;
    const variant = @as(u2, 0x2);
    const md5_low = @as(u62, @truncate(hash_bits));

    var uuid: UUID = 0;
    uuid |= @as(UUID, md5_high) << 80;
    uuid |= @as(UUID, md5_mid_and_vers) << 64;
    uuid |= @as(UUID, variant) << 62;
    uuid |= @as(UUID, md5_low);

    return uuid;
}

test {
    const namespace = 0x84401971b835468f866d2915ddffc772;
    var g = init(namespace);
    const id = g.new("DNS");
    const vers = try lib.version(id);
    const variant = lib.variant(id);
    try testing.expectEqual(vers, lib.Version.v3);
    try testing.expectEqual(variant, lib.Variant.rfc4122);
}
