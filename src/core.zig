const std = @import("std");
const mem = std.mem;
const testing = std.testing;

/// Represents a UUID as a 128-bit unsigned integer.
///
/// Internally, UUIDs are 16 bytes (128 bits). This type alias is used
/// throughout the library to make it clear when a value is a UUID.
pub const UUID = u128;

pub const Variant = enum {
    ncs,
    ms,
    rfc4122,
};

/// Enumeration of all UUID versions defined by RFC 4122 and newer drafts.
///
/// Each version corresponds to a different generation strategy
pub const Version = enum {
    /// Time-based
    v1,
    /// DCE Security (time + POSIX UID/GID)
    v2,
    /// Name-based (MD5 hashing)
    v3,
    /// Random
    v4,
    /// Name-based (SHA-1 hashing)
    v5,
    /// Reordered time-based (proposed, time-ordered UUIDs)
    v6,
    /// Unix time + random bits (proposed, recommended for many cases)
    v7,
    /// Custom application-defined format (proposed, reserved)
    v8,
};

pub const NIL: UUID = 0;
pub const MAX: UUID = std.math.maxInt(UUID);

/// Errors that can occur when determining a UUID version.
pub const VersionError = error{
    /// The version field did not correspond to any recognized version.
    Undefined,
};

/// Represents a parsed UUID along with its detected version.
pub const ParsedUUID = struct {
    /// The raw 128-bit UUID value.
    uuid: UUID,
    /// The extracted UUID version.
    version: Version,
};

/// Returns the UUID version extracted from the given UUID value.
///
/// The function interprets the 128-bit UUID in **network byte order**
/// (big-endian) by swapping endianness first. It then extracts the
/// 4-bit version field (located in the `time_hi_and_version` field,
/// bits 76–79 of the UUID as defined in [RFC 4122]).
///
/// # Parameters
/// - `uuid`: The UUID value as a `u128`.
///
/// # Returns
/// - The corresponding `Version` enum if the version is recognized (1–8).
/// - `VersionError.UndefinedVersion` if the version field does not match
///   any known UUID version.
///
/// # Example
/// ```zig
/// const uuid: u128 = 0xf47ac10b58cc4372a5670e02b2c3d479;
/// const v = try version(uuid);
/// std.debug.print("Version: {}\n", .{v});
/// ```
pub fn version(uuid: UUID) VersionError!Version {
    const flag = @as(u4, @truncate(uuid >> 76));
    return switch (flag) {
        1 => Version.v1,
        2 => Version.v2,
        3 => Version.v3,
        4 => Version.v4,
        5 => Version.v5,
        6 => Version.v6,
        7 => Version.v7,
        8 => Version.v8,
        else => VersionError.Undefined,
    };
}

pub fn variant(uuid: UUID) Variant {
    const flag = @as(u2, @truncate(uuid >> 62));
    return switch (flag) {
        0b00, 0b01 => .ncs,
        0b10 => .rfc4122,
        0b11 => .ms,
    };
}

pub fn stringify(uuid: UUID) [36]u8 {
    const big = std.mem.nativeToBig(UUID, uuid);
    const bytes = std.mem.asBytes(&big);

    var result: [36]u8 = undefined;

    // Format: 8-4-4-4-12
    _ = std.fmt.bufPrint(
        &result,
        "{x:0>2}{x:0>2}{x:0>2}{x:0>2}-" ++
            "{x:0>2}{x:0>2}-" ++
            "{x:0>2}{x:0>2}-" ++
            "{x:0>2}{x:0>2}-" ++
            "{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}",
        .{
            bytes[0],  bytes[1],  bytes[2],  bytes[3],
            bytes[4],  bytes[5],  bytes[6],  bytes[7],
            bytes[8],  bytes[9],  bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15],
        },
    ) catch unreachable;

    return result;
}

test "stringify a UUID" {
    const id = 0x84401971b835468f866d2915ddffc772;
    const text_id = stringify(id);
    try testing.expect(std.mem.eql(u8, &text_id, "84401971-b835-468f-866d-2915ddffc772"));
}
