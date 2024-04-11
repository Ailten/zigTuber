const ValuePrintable = @import("../value_printable.zig").ValuePrintable;
const c = @import("../c.zig"); //import all C lib declared.

pub const DataParam = struct { //struct for canva params.
    zoom: f16 = 1, //scale all layer and window.

    fps: u8 = 30, //frame draw per seconde.

    speed_anime: f32 = 1.0, //speed of anime of all layer.

    talking_anime_span_size: u32 = 4000, //miliseconde for one loop anime talking.
    speed_talking: f32 = 1.0, //speed of anime talking.

    min_decibel_for_talking: f64 = 5.0, //value min for distinct talk.
    sensitivity_microphone: f64 = 40.0, //sensitivity of microphone.

    jump_high_when_talking: c_int = 15, //pixel hight jump of all layers when talking.

    read_file_accesory: bool = true, //bool if the exe have to check file accesory every update.
};

pub const DataParamPrintable = struct {
    zoom: ValuePrintable(f16) = ValuePrintable(f16){}, //scale all layer and window.

    fps: ValuePrintable(u8) = ValuePrintable(u8){}, //frame draw per seconde.

    speed_anime: ValuePrintable(f32) = ValuePrintable(f32){}, //speed of anime of all layer.

    talking_anime_span_size: ValuePrintable(u32) = ValuePrintable(u32){}, //miliseconde for one loop anime talking.
    speed_talking: ValuePrintable(f32) = ValuePrintable(f32){}, //speed of anime talking.

    min_decibel_for_talking: f64 = 5.0, //value min for distinct talk.
    sensitivity_microphone: f64 = 40.0, //sensitivity of microphone.

    jump_high_when_talking: ValuePrintable(c_int) = ValuePrintable(c_int){}, //pixel hight jump of all layers when talking.

    read_file_accesory: bool = true, //bool if the exe have to check file accesory every update.

    pub fn import_data(data_import: DataParam, renderer_send: *c.SDL_Renderer) @This() {
        var out = @This(){
            .zoom = .{},
            .fps = .{},
            .speed_anime = .{},
            .talking_anime_span_size = .{},
            .speed_talking = .{},
            .min_decibel_for_talking = data_import.min_decibel_for_talking,
            .sensitivity_microphone = data_import.sensitivity_microphone,
            .jump_high_when_talking = .{},
            .read_file_accesory = data_import.read_file_accesory,
        };

        out.zoom.init(data_import.zoom, renderer_send);
        out.fps.init(data_import.fps, renderer_send);
        out.speed_anime.init(data_import.speed_anime, renderer_send);
        out.talking_anime_span_size.init(data_import.talking_anime_span_size, renderer_send);
        out.speed_talking.init(data_import.speed_talking, renderer_send);
        out.jump_high_when_talking.init(data_import.jump_high_when_talking, renderer_send);

        return out;
    }

    pub fn export_data(self: @This()) DataParam {
        return .{
            .zoom = self.zoom.get(),
            .fps = self.fps.get(),
            .speed_anime = self.speed_anime.get(),
            .talking_anime_span_size = self.talking_anime_span_size.get(),
            .speed_talking = self.speed_talking.get(),
            .min_decibel_for_talking = self.min_decibel_for_talking,
            .sensitivity_microphone = self.sensitivity_microphone,
            .jump_high_when_talking = self.jump_high_when_talking.get(),
            .read_file_accesory = self.read_file_accesory,
        };
    }
};
