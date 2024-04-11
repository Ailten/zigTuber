// miniaudio_wrapper.zig

const std = @import("std");
const c = @import("c.zig"); //import all C lib declared.
const Update = @import("update.zig").Update;
const Mutex = @import("mutex.zig").Mutex;
const ValuePrintable = @import("value_printable.zig").ValuePrintable;

pub const AudioManager = struct {
    var context_config: c.ma_context_config = undefined;
    var context: c.ma_context = undefined;
    var device_config: c.ma_device_config = undefined;
    var device: c.ma_device = undefined;

    //var buffer: std.ArrayList(u8) = undefined;
    //var ring_buffer: c.ma_pcm_rb = undefined;
    var buffer_mutex: Mutex = .{};
    var buffer_size: usize = undefined;

    const format: c_int = c.ma_format_s16; //c.ma_format_f32;
    const channels: c_uint = 1; //2;
    const sample_rate: c_uint = 44100;
    const ring_size_in_frames: c.ma_uint32 = 1024; //4096;

    pub var last_decibel_mesure: f64 = 0.0; //last decibel recorded.
    pub var min_decibel_for_talking: f64 = 5.0; //volume expected for active talking anime.

    pub var sensitivity_microphone: ValuePrintable(f64) = ValuePrintable(f64){}; //microphone sencibility (more height = more sensitiv).

    var last_time_clean_buffer: u32 = 0;
    const intervale_clean_buffer: u32 = 30;

    pub fn init() !void { //allocator: std.mem.Allocator
        AudioManager.context_config = c.ma_context_config_init();

        AudioManager.context = undefined;
        if (c.ma_context_init(
            null,
            0,
            &AudioManager.context_config,
            &AudioManager.context,
        ) != c.MA_SUCCESS) {
            std.log.err("error for init context miniaudio", .{});
            return error.UnableToInitializeMiniaudio;
        }

        const sample_size_in_bytes = c.ma_get_bytes_per_sample(AudioManager.format);
        const frame_size_in_bytes = sample_size_in_bytes * AudioManager.channels;
        AudioManager.buffer_size = AudioManager.ring_size_in_frames * frame_size_in_bytes;
        //AudioManager.buffer = try std.ArrayList(u8).initCapacity(allocator, AudioManager.buffer_size);
        //AudioManager.buffer.expandToCapacity();

        //AudioManager.ring_buffer = undefined;
        //const ring_buffer_init_result = c.ma_pcm_rb_init(
        //    AudioManager.format,
        //    AudioManager.channels,
        //    AudioManager.ring_size_in_frames,
        //    @ptrCast(&AudioManager.buffer),
        //    null,
        //    &AudioManager.ring_buffer,
        //);
        //if (ring_buffer_init_result != c.MA_SUCCESS) {
        //    std.log.err("error for init ring buffer miniaudio", .{});
        //    return error.UnableToInitRingBufferMiniaudio;
        //}

        AudioManager.device_config = c.ma_device_config_init(c.ma_device_type_capture);
        AudioManager.device_config.capture.format = AudioManager.format;
        AudioManager.device_config.capture.channels = AudioManager.channels;
        AudioManager.device_config.sampleRate = AudioManager.sample_rate;
        AudioManager.device_config.dataCallback = AudioManager.dataCallback;
        AudioManager.device_config.pUserData = null; //@ptrCast(&AudioManager.ring_buffer);

        AudioManager.device = undefined;
        const device_result = c.ma_device_init( //open peripheric capture.
            &AudioManager.context,
            &AudioManager.device_config,
            &AudioManager.device,
        );
        if (device_result != c.MA_SUCCESS) {
            std.log.err("error for init device miniaudio", .{});
            return error.UnableToInitializeDeviceMiniaudio;
        }

        const start_result = c.ma_device_start(&AudioManager.device); //start capture audio.
        if (start_result != c.MA_SUCCESS) {
            std.log.err("error for start device miniaudio", .{});
            return error.UnableToStartDeviceMiniaudio;
        }
    }

    pub fn deinit() void {
        c.ma_device_uninit(&AudioManager.device);
        _ = c.ma_context_uninit(&AudioManager.context);
        //c.ma_pcm_rb_uninit(&AudioManager.ring_buffer);
        //AudioManager.buffer.deinit();
    }

    pub fn dataCallback(
        p_device: [*c]c.ma_device, //pointer device.
        p_output_anyopaque: ?*anyopaque, //pointer output, anyopaque type, nullable.
        p_input_anyopaque: ?*const anyopaque, //pointer input, anyopaque, nullable, const.
        frame_count: c_uint, //frame_count.
    ) callconv(.C) void {
        _ = p_device; //not use.
        _ = p_output_anyopaque;
        _ = frame_count;

        AudioManager.buffer_mutex.lock(20);

        //cast to non null.
        const p_input_anyopaque_nonull: *const anyopaque = p_input_anyopaque orelse {
            std.log.err("error for cast input dataCallback miniaudio", .{});
            return;
        };

        //cast input anyopaque to slice i16 (PCM, Pulse Code Modulation).
        const input_slice_size: usize = AudioManager.buffer_size / 2;
        const input_slice: []const i16 = @as([*]const i16, @alignCast(@ptrCast(p_input_anyopaque_nonull)))[0..input_slice_size];

        //process audio data input.
        for (input_slice) |sample| {
            const spl = AudioManager.convertToSpl(sample);

            if (spl > AudioManager.last_decibel_mesure) {
                AudioManager.last_decibel_mesure = spl; //save if dB is biger.
            }
        }

        //std.debug.print(
        //    " --- dB {d:.2} / {d:.2} => {s}\n",
        //    .{
        //        AudioManager.last_decibel_mesure,
        //        AudioManager.min_decibel_for_talking,
        //        if (AudioManager.isTalking()) "[V]" else "[ ]",
        //    },
        //);

        AudioManager.buffer_mutex.unlock(20);

        return;
    }

    fn convertToSpl(sample: i16) f64 {
        //a short vertion of cast.

        if (sample == 0) //exeption for not return -inf.
            return 0.0;

        const sample_abs = @abs(sample); //exeption for not return "NaN".

        const reference_voltage = 1.0; //reference tension (exemple : 1 volt)
        const sensitivity = AudioManager.sensitivity_microphone.get(); //0.1 //mirophone sensitivity (exemple : 0.1 dB/mV)
        const ref_value = 32768.0; //value ref for echantillon PCM full range i16.
        const ref_pressure = 20.0; //pressure for ref pascals (20 microPascals).

        const voltage = @as(f64, @floatFromInt(sample_abs)) / ref_value * reference_voltage; //convert to tention.
        const spl = ref_pressure * std.math.log10(voltage) + sensitivity; //convert tention to spl (decibel).
        return spl;
    }

    pub fn clearBufferSafely() void {
        const time_from_last_clean = Update.time - AudioManager.last_time_clean_buffer;
        if (time_from_last_clean < AudioManager.intervale_clean_buffer)
            return;

        AudioManager.last_time_clean_buffer = Update.time;

        AudioManager.buffer_mutex.lock(40);
        //c.ma_pcm_rb_reset(&AudioManager.ring_buffer);
        //AudioManager.last_decibel_mesure = 0.0;
        if (AudioManager.last_decibel_mesure > AudioManager.min_decibel_for_talking * 2) {
            AudioManager.last_decibel_mesure = AudioManager.min_decibel_for_talking * 2;
        } else {
            AudioManager.last_decibel_mesure = @max(AudioManager.last_decibel_mesure - 0.5, 0.0);
        }
        AudioManager.buffer_mutex.unlock(40);
    }

    pub fn isTalking() bool {
        return AudioManager.last_decibel_mesure > AudioManager.min_decibel_for_talking;
    }
};
