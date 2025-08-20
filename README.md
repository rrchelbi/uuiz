# uuiz 🆔
**uuiz** - Because every identity deserves a unique one. 🆔

[![Zig](https://img.shields.io/badge/Zig-0.14.0-%23f7a41d.svg)](https://ziglang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://github.com/rrchelbi/uuiz/actions/workflows/ci.yml/badge.svg)](https://github.com/rrchelbi/uuiz/actions)

A lightweight, zero-dependency UUID library for Zig. Provides RFC 4122 compliant UUID generation, parsing, and manipulation with a focus on performance and type safety.

## Features

- ✅ **RFC 4122 Compliant** - Full support for UUID specification
- 🚀 **Zero Dependencies** - Only requires the Zig standard library
- 🔒 **Type Safe** - Strong typing throughout the API

## Installation

1. Run zig fetch:
```bash
$ zig fetch --save git+https://www.github.com/rrchelbi/uuiz#main
```

After this your `build.zig.zon` should look like this:
```zig
.{
    // other attributes
    // ...

    .dependencies = .{
        // other dependencies
        // ...

        .uuiz = .{
            .url = "https://github.com/your-username/uuiz/archive/refs/tags/v0.1.0.tar.gz",
            .hash = "1220...",
        },
    },
}
```

2. Add the module to your `build.zig`:
```zig
const uuiz = b.dependency("uuiz", .{
    .target = target,
    .optimize = optimize,
});

exe.addModule("uuiz", uuiz.module("uuiz"));
```

## Quick Start

```zig
const std = @import("std");
const uuiz = @import("uuiz");

pub fn main() !void {
    const uuid = uuiz.v4.new();
    std.debug.print("Generated v4 UUID: {}\n", .{uuid});
}
```

## API Reference

### Core Types

```zig
// Main UUID type (128 bits)
const UUID = u128;

// UUID versions
const Version = enum {
    V1, // Time-based
    V2, // DCE Security
    V3, // MD5 hash
    V4, // Random
    V5, // SHA-1 hash
    V6, // Ordered time-based
    V7, // Unix timestamp-based
    V8, // Custom
};

// Layout struct for direct field access
const Layout = struct {
    clock_seq_hi_and_res: u8,
    clock_seq_low: u8,
    time_mid: u16,
    time_hi_and_version: u16,
    time_low: u32,
    node: u48,
};
```

## Version Support

| Version | Status | Description |
|---------|--------|-------------|
| v1 |    | Time-based with MAC address |
| v2 |    | DCE Security |
| v3 |    | MD5 namespace-based |
| v4 | ✅ | Random (cryptographically secure) |
| v5 |    | SHA-1 namespace-based |
| v6 |    | Ordered time-based |
| v7 |    | Unix timestamp-based |
| v8 |    | Custom format |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- RFC 4122 UUID specification
- Zig community for best practices
- Contributors and testers

