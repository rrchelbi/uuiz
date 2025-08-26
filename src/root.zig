//! UUIZ (UUID) Library Entry Point
//!
//! This module provides a unified interface for working with UUIDs in Zig,
//! re-exporting core types and utilities as well as version-specific UUID generators.
//!
//! ## Example
//! ```zig
//! const uuid = @import("uuiz");
//!
//! // Generate Version 4 UUID (random)
//! const random_uuid = uuid.v4.new();
//!
//! // Generate Version 1 UUID (time-based)
//! var gen = uuid.v1.init();
//! const time_uuid = gen.new();
//!
//! // Get UUID version
//! const ver = try uuid.version(random_uuid);
//! ```
//!
//! ## Exported Components
//! - **UUID**: Core 128-bit UUID type
//! - **Variant**: Enumeration for UUID variants (RFC 4122, Microsoft, etc.)
//! - **Version**: Enumeration for UUID versions (v1, v4, etc.)
//! - **version()**: Retrieves UUID version from a given UUID
//! - **variant()**: Retrieves UUID variant from a given UUID
//! - **string()**: Converts a UUID to its canonical string representation
//! - **NIL**: Nil UUID (`00000000-0000-0000-0000-000000000000`)
//! - **MAX**: Max UUID (`ffffffff-ffff-ffff-ffff-ffffffffffff`)
//! - **v1**: Module for Version 1 UUID generation
//! - **v4**: Module for Version 4 UUID generation
//!
//! ## RFC 4122 Compliance
//! All UUID generation methods comply with RFC 4122 specifications for
//! version and variant fields.

const core = @import("core.zig");

pub const UUID = core.UUID;

pub const Variant = core.Variant;
pub const Version = core.Version;
pub const VersionError = core.VersionError;

pub const version = core.version;
pub const variant = core.variant;
pub const string = core.string;

pub const NIL = core.NIL;
pub const MAX = core.MAX;

pub const v1 = @import("v1.zig");
pub const v4 = @import("v4.zig");
