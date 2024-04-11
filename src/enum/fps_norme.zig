const FPS_NORME = [_]u8{
    15,
    20,
    25,
    30,
    60,
    120,
};

pub fn editFPS(fps_input: u8, edit: i2) u8 {
    for (FPS_NORME, 0..) |current_fps_norme, index| {
        if (current_fps_norme == fps_input) {
            const index_ask = @as(i16, @intCast(index)) + @as(i16, @intCast(edit));
            const index_clamp = @as(usize, @intCast(@as(i16, @intCast(FPS_NORME.len)) + index_ask)) % FPS_NORME.len;
            return FPS_NORME[index_clamp];
        }
    }
    return 60; //default return if not found in array.
}
