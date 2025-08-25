//! UUID Version 4 (Random UUID) Generation
//!
//! This module provides functionality for generating and working with
//! UUID version 4 as specified in RFC 4122. Version 4 UUIDs are
//! randomly or pseudo-randomly generated identifiers that provide
//! a very low probability of collision.
//!
//! ## Features
//! - Cryptographically secure random generation using std.crypto.random
//! - Proper setting of version and variant fields according to RFC 4122
//! - Basic parsing functionality (placeholder implementation)
//!
//! ## Example
//! ```zig
//! const uuid = v4.new();
//! // uuid is now a valid version 4 UUID with proper variant bits
//! ```
//!
//! ## RFC 4122 Compliance
//! The generated UUIDs comply with section 4.4 of RFC 4122:
//! - Version field (bits 12-15): set to 0100 (4)
//! - Variant field (bits 6-7): set to 10 (RFC 4122 variant)
//! - All other bits: random

const std = @import("std");
const testing = std.testing;
const rand = std.crypto.random;

const core = @import("core.zig");

const UUID = core.UUID;
const ParseError = core.ParseError;

/// Generates a new random UUID version 4 (random UUID)
///
/// This function creates a UUID according to RFC 4122 version 4 specification,
/// which uses random or pseudo-random numbers for all bits except for the
/// version and variant fields which are set according to the specification.
///
/// Returns: A new randomly generated UUID v4
pub fn new() UUID {
    var uuid: UUID = rand.int(UUID);
    uuid = (uuid & ~(@as(UUID, 0xF) << 76)) | (@as(UUID, 0x4) << 76);
    uuid = (uuid & ~(@as(UUID, 0x3) << 62)) | (@as(UUID, 0x2) << 62);
    return uuid;
}

pub fn from(unknown: []const u8) ParseError!UUID {
    _ = unknown;
    return new();
}

test "generate valid v4 uuid" {
    const id = new();
    const vers = try core.version(id);
    const variant = try core.variant(id);
    try testing.expectEqual(vers, core.Version.v4);
    try testing.expectEqual(variant, core.Variant.rfc4122);
}
