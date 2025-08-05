const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("zigmon", .{
        .root_source_file = b.path("src/zigmon.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    module.addIncludePath(b.path("src/dmon"));
    module.addCSourceFile(.{
        .file = b.path("src/dmon/dmon.c"),
        .flags = &.{
            // "-std=c99",
            "-fno-sanitize=undefined",
        },
    });

    {
        const demo_raw_mod = b.createModule(.{
            .root_source_file = b.path("src/demos/raw.zig"),
            .target = target,
            .optimize = optimize,
        });

        demo_raw_mod.addImport("zigmon", module);

        const demo_raw = b.addExecutable(.{
            .name = "zigmod-demo-raw",
            .root_module = demo_raw_mod,
        });

        const demo_cmd = b.addRunArtifact(demo_raw);
        demo_cmd.step.dependOn(b.getInstallStep());

        const demo_step = b.step("demo-raw", "Run the raw binding demo");
        demo_step.dependOn(&demo_cmd.step);
    }

    {
        const demo_raw = b.createModule(.{
            .root_source_file = b.path("src/demos/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        demo_raw.addImport("zigmon", module);

        const demo = b.addExecutable(.{
            .name = "zigmod-demo",
            .root_module = demo_raw,
        });

        const demo_cmd = b.addRunArtifact(demo);
        demo_cmd.step.dependOn(b.getInstallStep());

        const demo_step = b.step("demo", "Run the demo");
        demo_step.dependOn(&demo_cmd.step);
    }
}
