last_timestamp: u64 = 0,
sequence: u14 = 0,
node_id: u48,
clock_seq: u14,

const Random = std.Random;
const time = std.time;
const UUID = core.UUID;

const UUID_V1_EPOCH: i64 = 0x01B21DD213814000; // Oct 15, 1582 in 100ns intervals

const Self = @This();

pub fn init() Self {
    const seed = @as(u64, @bitCast(time.timestamp()));
    var prng = Random.DefaultPrng.init(seed);
    const rand = prng.random();

    return .{
        .node_id = rand.int(u48),
        .clock_seq = rand.int(u14),
    };
}

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

const core = @import("core.zig");
const std = @import("std");
