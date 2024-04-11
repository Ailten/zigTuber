const std = @import("std"); //lib base.
const JsonManager = @import("json_manager.zig").JsonManager;

pub const Update = struct { //struct.

    pub var milisec_by_frame: u16 = 0;

    pub var time: u32 = 0; //time increasing every update.

    pub fn eval_milisec_by_frame(fps: u8) void { //eval and stock the fps value in milisec.
        Update.milisec_by_frame = (1000 / @as(u16, fps));
    }

    pub fn get_sin_wave(intencity: i16, time_speed: f32) i16 {
        return Update.get_wave_anime(intencity, time_speed, false);
    }
    pub fn get_cos_wave(intencity: i16, time_speed: f32) i16 {
        return Update.get_wave_anime(intencity, time_speed, true);
    }
    pub fn get_wave_anime(intencity: i16, time_speed: f32, cos: bool) i16 {
        const time_float_sec: f32 = @as(f32, @floatFromInt(Update.time)) / 1000.0; //cast time to sec in float (need float for sin).
        const time_multiply = time_float_sec * time_speed; //apply time speed modifier.
        const sin_wave = if (cos) @cos(time_multiply) else @sin(time_multiply); //get wave curve.
        const sin_multiply = sin_wave * @as(f32, @floatFromInt(intencity)) * JsonManager.data_params.zoom.get(); //apply intencity modifier.
        return @intFromFloat(sin_multiply);
    }

    var milisec_before_process: i64 = 0; //miliseconde before process of current update.
    var milisec_after_process: i64 = 0; //miliseconde after process of current update.

    pub fn saveTimeBeforeProcess() void {
        Update.milisec_before_process = std.time.milliTimestamp();
    }
    pub fn saveTimeAfterProcess() void {
        Update.milisec_after_process = std.time.milliTimestamp();
    }

    pub fn waitEndProcess() void {
        var time_for_process = @as(
            u16,
            @intCast(Update.milisec_after_process - Update.milisec_before_process),
        );
        if (time_for_process > Update.milisec_by_frame) {
            const frame_skip = time_for_process / Update.milisec_by_frame;
            time_for_process = time_for_process % Update.milisec_by_frame; //eval time to wait for next frame valide.
            Update.time += Update.milisec_by_frame * frame_skip; //increate time of all frames skiped.
        }

        const sleep_value: u64 = @as(u64, (Update.milisec_by_frame - time_for_process)) * std.time.ns_per_ms;
        std.time.sleep(sleep_value); //wait end of frame.
        Update.time += Update.milisec_by_frame; //increate time current frame.
    }
};
