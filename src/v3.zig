const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const Md5 = std.crypto.hash.Md5;

const lib = @import("root.zig");
const UUID = lib.UUID;

namespace: UUID,

pub const Namespace = struct {
    pub const DNS: UUID = 0x6ba7b8109dad11d180b400c04fd430c8;
    pub const URL: UUID = 0x6ba7b8119dad11d180b400c04fd430c8;
    pub const OID: UUID = 0x6ba7b8129dad11d180b400c04fd430c8;
    pub const X500: UUID = 0x6ba7b8149dad11d180b400c04fd430c8;
};


const Self = @This();

pub fn init(namespace: UUID) Self {
    return .{
        .namespace = namespace,
    };
}

pub fn new(self: Self, name: []const u8) UUID {
    var hash: [16]u8 = undefined;
    const bytes = std.mem.asBytes(&self.namespace);

    var context = Md5.init(.{});
    context.update(bytes[0..]);
    context.update(name);
    context.final(&hash);

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

test "generate valid v3 uuid" {
    const g = init(Namespace.DNS);
    const id = g.new("uuiz");
    const vers = try lib.version(id);
    const variant = lib.variant(id);
    try testing.expectEqual(vers, lib.Version.v3);
    try testing.expectEqual(variant, lib.Variant.rfc4122);
}

test "v3 uuid with the same namespace and the same name should produce same uuid" {
    const g = init(Namespace.DNS);
    const id1 = g.new("uuiz");
    const id2 = g.new("uuiz");
    try testing.expectEqual(id1, id2);
}
