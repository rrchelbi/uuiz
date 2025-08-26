//! UUID Version 1 (Time-based UUID) Generation
//!
//! This module provides functionality for generating and working with
//! UUID version 1 as specified in RFC 4122. Version 1 UUIDs are based on
//! the current timestamp, clock sequence, and node identifier, ensuring
//! uniqueness across time and nodes.
//!
//! ## Features
//! - Time-based UUID generation using system time in 100-nanosecond intervals
//! - Proper setting of version (v1) and variant fields according to RFC 4122
//! - Maintains sequence to avoid collisions within the same timestamp
//! - Randomized node identifier and clock sequence for uniqueness across machines
//!
//! ## Example
//! ```zig
//! var gen = v1.init();
//! const uuid = gen.new();
//! // uuid is now a valid version 1 UUID with proper variant and version bits
//! ```
//!
//! ## RFC 4122 Compliance
//! The generated UUIDs comply with section 4.2 of RFC 4122:
//! - **Version field (bits 12-15):** set to 0001 (1)
//! - **Variant field (bits 6-7):** set to 10 (RFC 4122 variant)
//! - **Time fields:** represent timestamp in 100-ns intervals since 1582-10-15
//! - **Node and Clock Sequence:** randomized for uniqueness
//!
//! ## Notes
//! - This implementation uses `std.time.nanoTimestamp()` for time retrieval
//! - If multiple UUIDs are generated within the same timestamp, a 14-bit sequence counter ensures uniqueness

const std = @import("std");
const testing = std.testing;
const Random = std.Random;
const time = std.time;

const lib = @import("root.zig");
const UUID = lib.UUID;

/// Last generated timestamp in 100-nanosecond units
last_timestamp: u64 = 0,
/// Sequence counter to avoid duplicates within the same timestamp
sequesce: u14 = 0,
/// Randomly generated 48-bit node identifier
node_id: u48,
/// Randomly generated 14-bit clock sequence
clock_seq: u14,

const UUID_V1_EPOCH: i64 = 0x01B21DD213814000; // Oct 15, 1582 in 100ns intervals

const Self = @This();

/// Initializes a new UUID v1 generator
///
/// This function seeds a pseudo-random generator with the current system timestamp,
/// then generates a random node identifier (48 bits) and clock sequence (14 bits).
///
/// Returns: A new instance of the UUID v1 generator.
pub fn init() Self {
    const seed = @as(u64, @bitCast(time.timestamp()));
    var prng = Random.DefaultPrng.init(seed);
    const rand = prng.random();

    return .{
        .node_id = rand.int(u48),
        .clock_seq = rand.int(u14),
    };
}

/// Generates a new UUID version 1
///
/// This function constructs a UUID using the current timestamp (in 100ns intervals since the UUID epoch),
/// the node identifier, and the clock sequence. The version and variant bits are set according to RFC 4122.
///
/// Returns: A new UUID v1 as a 128-bit integer.
pub fn new(self: *Self) UUID {
    const timestamp = self.gettimestamp();
    const time_low = @as(u32, @truncate(timestamp));
    const time_mid = @as(u16, @truncate(timestamp >> 32));
    const time_high_and_vers = (@as(u16, @truncate(timestamp >> 48)) & 0x0FFF) | 0x1000;
    const variant = @as(u16, 0x2) << 14;
    const clock_seq = self.clock_seq & 0x3FFF;

    var uuid: UUID = 0;
    uuid |= @as(UUID, time_low) << 96;
    uuid |= @as(UUID, time_mid) << 80;
    uuid |= @as(UUID, time_high_and_vers) << 64;
    uuid |= @as(UUID, variant | clock_seq) << 48;
    uuid |= self.node_id;

    return uuid;
}

/// Retrieves the current timestamp in 100ns intervals since the UUID epoch
///
/// If the timestamp is the same as the last generated timestamp, the sequence counter is incremented.
/// Otherwise, the sequence counter is reset to zero.
///
/// Returns: The current timestamp adjusted for the UUID v1 epoch.
fn gettimestamp(self: *Self) u64 {
    const now_ns = time.nanoTimestamp();
    const timestamp_100ns = @as(u64, @intCast(now_ns)) / 100 + @as(u64, @intCast(UUID_V1_EPOCH));

    if (timestamp_100ns <= self.last_timestamp) {
        self.sequence +%= 1;
    } else {
        self.sequence = 0;
    }

    self.last_timestamp = timestamp_100ns;
    return timestamp_100ns;
}

test "generate valid uuid v1" {
    var g = init();
    const id = g.new();
    const vers = try lib.version(id);
    const variant = lib.variant(id);
    try testing.expectEqual(vers, lib.Version.v1);
    try testing.expectEqual(variant, lib.Variant.rfc4122);
}
