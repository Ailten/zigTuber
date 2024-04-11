const std = @import("std");

//function when build.
pub fn build(b: *std.Build) void {

    //os and octe management.
    const target = b.standardTargetOptions(.{});

    //mode rapide, mode safe, mode light.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ //the final exe build.
        .name = "ZigTuber",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    //exe.addLibPath("/usr/include/"); //lib path for window build.
    //exe.addIncludeDir("/usr/include");
    //exe.addLibPath("/usr/lib");
    //exe.linkSystemLibrary("SDL2");

    exe.linkSystemLibrary("sdl2"); //build lib sdl in exe.

    exe.linkSystemLibrary("sdl2_image"); //build lib sdl for surface in exe.

    exe.linkSystemLibrary("sdl2_ttf"); //build lib sdl for font/text in exe.

    exe.linkLibC(); //import lib standard C.

    exe.addCSourceFile(.{
        .file = std.Build.LazyPath.relative("lib/miniaudio/miniaudio.c"),
    });

    exe.addIncludePath(std.Build.LazyPath.relative("lib/miniaudio"));

    b.installArtifact(exe); //do the step exe when build app.

    const run_cmd = b.addRunArtifact(exe); //do the step exe when commande run.

    run_cmd.step.dependOn(b.getInstallStep()); //when run, do install before.

    if (b.args) |args| { //give argument of build to the run comande.
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app"); //step run.
    run_step.dependOn(&run_cmd.step);
}
