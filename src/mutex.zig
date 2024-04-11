const std = @import("std");

pub const Mutex = struct {
    //mutex: std.Thread.Mutex = .{},

    bool_lock: bool = false,
    priority: u8 = 0,

    pub fn lock(self: *@This(), priority: u8) void {
        while (true) {
            if (!self.bool_lock and self.priority <= priority) //not occuped and I am more importent than the ocuper.
                break; //so I take the place.

            if (self.bool_lock and self.priority < priority) //ocuped and I am more importent than the ocuper.
                self.priority = priority; //so I keep wait, but I mark my priority.

            std.time.sleep(10); //wait.
        }
        self.priority = priority; //when I took the place, I mark my level of importens.
        self.bool_lock = true; //I lock the place.
    }

    pub fn unlock(self: *@This(), priority: u8) void {
        if (self.priority == priority) //if I leave the place and no one more important than me are waiting.
            self.priority = 0; //I reset the priority.
        self.bool_lock = false; //I leave the place.
    }
};
