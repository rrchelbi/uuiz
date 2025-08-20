const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("uuiz", .{
        .root_source_file = b.path("src/root.zig"),
    });

    const mod_test = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "uuiz",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .imports = &.{
                .{ .name = "uuiz", .module = mod },
            },
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_exe = b.addRunArtifact(exe);
    const exe_step = b.step("run", "Run the executable build");
    exe_step.dependOn(&run_exe.step);

    const run_mod_tests = b.addRunArtifact(mod_test);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_mod_tests.step);
}
