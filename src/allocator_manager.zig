const std = @import("std"); //lib base.

pub const AllocatorManager = struct {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = undefined;
    pub var allocator: std.mem.Allocator = undefined;

    var arena: std.heap.ArenaAllocator = undefined;
    pub var arena_allocator: std.mem.Allocator = undefined;

    pub var arena_update: std.heap.ArenaAllocator = undefined;
    pub var arena_update_allocator: std.mem.Allocator = undefined;

    pub fn init() void {
        AllocatorManager.gpa = std.heap.GeneralPurposeAllocator(.{}){}; //alocator.
        AllocatorManager.allocator = gpa.allocator();

        AllocatorManager.arena = std.heap.ArenaAllocator.init(allocator);
        AllocatorManager.arena_allocator = arena.allocator();

        AllocatorManager.arena_update = std.heap.ArenaAllocator.init(allocator);
        AllocatorManager.arena_update_allocator = arena_update.allocator();
    }

    pub fn deinit() void {
        AllocatorManager.arena_update.deinit();
        AllocatorManager.arena.deinit();
        _ = AllocatorManager.gpa.deinit();
    }
};
