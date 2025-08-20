/// Represents a UUID as a 128-bit unsigned integer.
///
/// Internally, UUIDs are 16 bytes (128 bits). This type alias is used
/// throughout the library to make it clear when a value is a UUID.
pub const UUID = u128;

pub const Variant = enum {
    NCS,
    MS,
    FutureDefinition,
    RFC4122,
};

/// Enumeration of all UUID versions defined by RFC 4122 and newer drafts.
///
/// Each version corresponds to a different generation strategy
pub const Version = enum {
    /// Time-based
    V1,
    /// DCE Security (time + POSIX UID/GID)
    V2,
    /// Name-based (MD5 hashing)
    V3,
    /// Random
    V4,
    /// Name-based (SHA-1 hashing)
    V5,
    /// Reordered time-based (proposed, time-ordered UUIDs)
    V6,
    /// Unix time + random bits (proposed, recommended for many cases)
    V7,
    /// Custom application-defined format (proposed, reserved)
    V8,
};

/// Errors that can occur when determining a UUID version.
pub const VersionError = error{
    /// The version field did not correspond to any recognized version.
    UndefinedVersion,
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
    const big_uuid = mem.nativeToBig(UUID, uuid);
    const flag: u4 = @intCast((big_uuid >> 76) & 0xF);
    return switch (flag) {
        1 => Version.V1,
        2 => Version.V2,
        3 => Version.V3,
        4 => Version.V4,
        5 => Version.V5,
        6 => Version.V6,
        7 => Version.V7,
        8 => Version.V8,
        else => VersionError.UndefinedVersion,
    };
}

const Layout = struct {
    clock_seq_hi_and_res: u8,
    clock_seq_low: u8,
    time_mid: u16,
    time_hi_and_version: u16,
    time_low: u32,
    node: u48,
};

pub fn parse(uuid: UUID) Layout {
    const bytes = @as([16]u8, @bitCast(mem.nativeToBig(UUID, uuid)));
    return Layout{
        .time_low = mem.readInt(u32, bytes[0..4], builtin.Endian.big),
        .time_mid = mem.readInt(u16, bytes[4..6], builtin.Endian.big),
        .time_hi_and_version = mem.readInt(u16, bytes[6..8], builtin.Endian.big),
        .clock_seq_hi_and_res = bytes[8],
        .clock_seq_low = bytes[9],
        .node = mem.readInt(u48, bytes[10..16], builtin.Endian.big),
    };
}

const std = @import("std");
const mem = std.mem;
const builtin = std.builtin;
