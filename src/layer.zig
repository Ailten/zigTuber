const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const V2 = @import("v2.zig").V2;
const V2f = @import("v2.zig").V2f;
const DataParamLayer = @import("model/data_param_layer.zig").DataParamLayer;
const JsonManager = @import("json_manager.zig").JsonManager;
const TalkTypeLayer = @import("enum/talk_type_layer.zig").TalkTypeLayer;
const PropsTypeLayer = @import("enum/props_type_layer.zig").PropsTypeLayer;
const Update = @import("update.zig").Update;
const AudioManager = @import("miniaudio_wrapper.zig").AudioManager;
const ButtonLayer = @import("button_layer.zig").ButtonLayer;
const AllocatorManager = @import("allocator_manager.zig").AllocatorManager;
const ValuePrintable = @import("value_printable.zig").ValuePrintable;

pub const Layer = struct { //struct layer.

    is_active: bool = true, //layer need to be render.

    pos: V2 = .{ 0, 0 }, //position in environement.
    encrage: V2f = .{ 0, 0 }, //encrage of layer (for rotation).

    rotate: i16 = 0, //rotation of sprite in degre.

    scale: V2f = .{ 1, 1 }, //scale size multiplyer.

    texture: *c.SDL_Texture = undefined, //texture for the layer.
    texture_text: ?*c.SDL_Texture = null, //texture for the layer name.

    z_index: u16 = 0, //order render.

    name: std.ArrayList(u8) = undefined, //name of layer.

    talk_type: TalkTypeLayer = .both, //if layer need to be active or not depend on mic.
    props_type: PropsTypeLayer = .no_props, //if layer is a props or not.

    anime_ineticity_horizontal: ValuePrintable(i16) = ValuePrintable(i16){}, //intencity of anime for both axes.
    anime_ineticity_vertical: ValuePrintable(i16) = ValuePrintable(i16){},

    talking_anime_start: ValuePrintable(?u32) = ValuePrintable(?u32){}, //start and end in span talking.
    talking_anime_end: ValuePrintable(?u32) = ValuePrintable(?u32){},

    pub fn init(allocator: std.mem.Allocator, texture: *c.SDL_Texture, name_send: []const u8) !@This() {
        var layer_out: @This() = .{};

        layer_out.name = std.ArrayList(u8).init(allocator);
        errdefer layer_out.name.deinit();

        try layer_out.name.appendSlice(name_send);

        layer_out.texture = texture;

        return layer_out;
    }

    pub fn deinit(self: @This()) void {
        c.SDL_DestroyTexture(self.texture_text);
        c.SDL_DestroyTexture(self.texture);
        self.name.deinit();
    }

    pub fn loadLayers(
        renderer: *c.SDL_Renderer,
        layers: *std.ArrayList(@This()),
        path: []const u8,
    ) !void {
        var folder = try std.fs.cwd().openDir(
            path,
            .{ .iterate = true },
        );
        defer folder.close();

        var iterator = folder.iterate();
        var buffer: [256:0]u8 = undefined;
        while (try iterator.next()) |entry| {
            if (entry.kind != .file or //skip folders.
                !std.mem.endsWith(u8, entry.name, ".png") //skip not png.
            )
                continue;

            const path_current_file = std.fmt.bufPrint( //path of current file.
                &buffer,
                "{s}/{s}{c}",
                .{ path, entry.name, 0 },
            ) catch {
                std.log.err("error layer name to big : {s}", .{entry.name});
                continue;
            };

            const surface = c.IMG_Load(@ptrCast(path_current_file)) orelse { //build a surface for texture.
                std.log.err("error to load surface of file : {s}", .{path_current_file});
                std.log.err("{s}", .{c.SDL_GetError()});
                continue; //skip if one file can't get texture.
            };
            defer c.SDL_FreeSurface(surface);

            const texture = c.SDL_CreateTextureFromSurface(renderer, surface) orelse { //get texture frome file png.
                std.log.err("error to load texture of file : {s}", .{path_current_file});
                std.log.err("{s}", .{c.SDL_GetError()});
                continue; //skip if one file can't get texture.
            };

            const current_layer = try Layer.init(
                AllocatorManager.arena_allocator,
                texture,
                entry.name[0..(entry.name.len - 4)],
            );
            try layers.append(current_layer);
        }
    }

    pub fn loadParams(self: *@This(), data: DataParamLayer, renderer_menu: *c.SDL_Renderer) void {
        self.is_active = data.is_active;
        self.z_index = data.z_index;
        self.talk_type = data.talk_type;
        self.props_type = data.props_type;
        self.anime_ineticity_horizontal = .{};
        self.anime_ineticity_horizontal.init(data.anime_ineticity_horizontal, renderer_menu);
        self.anime_ineticity_vertical = .{};
        self.anime_ineticity_vertical.init(data.anime_ineticity_vertical, renderer_menu);
        self.talking_anime_start = .{};
        self.talking_anime_start.init(data.talking_anime_start, renderer_menu);
        self.talking_anime_end = .{};
        self.talking_anime_end.init(data.talking_anime_end, renderer_menu);
    }

    pub fn exportParams(self: @This()) DataParamLayer {
        return .{
            .is_active = self.is_active,
            .z_index = self.z_index,
            .talk_type = self.talk_type,
            .props_type = self.props_type,
            .anime_ineticity_horizontal = self.anime_ineticity_horizontal.get(),
            .anime_ineticity_vertical = self.anime_ineticity_vertical.get(),
            .talking_anime_start = self.talking_anime_start.get(),
            .talking_anime_end = self.talking_anime_end.get(),
        };
    }

    pub fn draw(self: *@This(), renderer: *c.SDL_Renderer) !void {
        if (!self.is_active)
            return;

        const talking_bool = AudioManager.isTalking(); //talking.
        if ((talking_bool and (self.talk_type == .no_talking)) or
            (!talking_bool and (self.talk_type == .talking)))
            return;

        if (talking_bool and (self.talk_type == .talking) and self.talking_anime_start.get() != null) { //talking anime many frame.
            const time_talk_speed: f32 = (@as(f32, @floatFromInt(Update.time)) * JsonManager.data_params.speed_talking.get());
            const time_talking_span = @as(u32, @intFromFloat(time_talk_speed)) % JsonManager.data_params.talking_anime_span_size.get();
            if (time_talking_span < self.talking_anime_start.get() orelse 0 or
                time_talking_span >= self.talking_anime_end.get() orelse 0)
                return;
        }

        const size = self.getSize();
        const pos = V2{
            self.pos[0] + Update.get_cos_wave(self.anime_ineticity_horizontal.get(), JsonManager.data_params.speed_anime.get()),
            self.pos[1] + Update.get_sin_wave(self.anime_ineticity_vertical.get(), JsonManager.data_params.speed_anime.get()),
        };
        var destination_rect: c.SDL_Rect = c.SDL_Rect{
            .x = pos[0], //pos to draw.
            .y = pos[1],
            .w = size[0], //size texture.
            .h = size[1],
        };

        if (talking_bool) //up based on talking.
            destination_rect.y -= @intCast(JsonManager.data_params.jump_high_when_talking.get());

        const error_code = c.SDL_RenderCopy( //draw a texture.
            renderer,
            self.texture,
            null, //part texture draw (all).
            &destination_rect, //pos to draw.
        );

        if (error_code != 0) { //error c to zig.
            return error.renderCopy;
        }
    }

    pub fn getSize(self: @This()) V2 {
        var size = self.getSizeBase();

        inline for (0..2) |i|
            size[i] = @intFromFloat(@as(f16, @floatFromInt(size[i])) //size from texture.
            * JsonManager.data_params.zoom.get() //multiply by resize zoom global.
            * self.scale[i] //multiply by scale layer.
            );

        return size;
    }

    pub fn getSizeBase(self: @This()) V2 {
        var x_c_int: c_int = undefined; //get size of texture.
        var y_c_int: c_int = undefined;

        _ = c.SDL_QueryTexture( //feed var c_int.
            self.texture,
            null,
            null,
            &x_c_int,
            &y_c_int,
        );

        const size = V2{ //size V2 from texture.
            @intCast(x_c_int),
            @intCast(y_c_int),
        };

        return size;
    }

    pub fn lessThan(_: void, a: @This(), b: @This()) bool { //function use to sort.
        return a.z_index < b.z_index;
    }

    pub fn switchAccesory(layers: *std.ArrayList(@This()), name_layer_accesory: []const u8) void {

        //get the layer accesory ask.
        var layer_accesory: ?*Layer = null;
        for (layers.items) |*layer| {
            if (std.mem.eql(u8, layer.name.items, name_layer_accesory)) {
                layer_accesory = layer;
                break;
            }
        }
        const layer_accesory_found: *Layer = layer_accesory orelse return;

        //if found but is a layer not alow to ask.
        if (layer_accesory_found.props_type == .no_props or
            layer_accesory_found.props_type == .mouth_talking)
            return;

        //do the active/unactive layer.
        layer_accesory_found.is_active = !layer_accesory_found.is_active;

        //if it's a props, active/unactive only this layer.
        if (layer_accesory_found.props_type == .props) {
            return;
        }

        //disable all layers the same type.
        for (layers.items) |*layer| {
            if (layer.props_type == layer_accesory_found.props_type and
                layer.z_index != layer_accesory_found.z_index)
            {
                layer.is_active = false;
            }
        }

        if (layer_accesory_found.is_active) { //if active, disable the layer active with same type.
            for (layers.items) |*layer_to_disable| {
                if (layer_to_disable.props_type != layer_accesory_found.props_type)
                    continue;
                if (layer_to_disable.props_type == .no_props or
                    layer_to_disable.props_type == .props or
                    layer_to_disable.props_type == .mouth_talking)
                    continue;
                if (layer_to_disable.z_index == layer_accesory_found.z_index)
                    continue;

                layer_to_disable.is_active = false;
            }
        } else if (layer_accesory_found.props_type == .eyes or
            layer_accesory_found.props_type == .mouth or
            layer_accesory_found.props_type == .hat)
        { //if disable layer and it's a layer need every tipe one type active, active the same type lowest index.
            var lowest_layer_z_index: ?*Layer = null;
            for (layers.items) |*layer_to_enable| {
                if (layer_to_enable.props_type != layer_accesory_found.props_type)
                    continue;
                if (layer_to_enable.z_index >= layer_accesory_found.z_index)
                    continue;
                if (lowest_layer_z_index) |lowest_layer_z_index_nonull| {
                    if (layer_to_enable.z_index >= lowest_layer_z_index_nonull.z_index)
                        continue;
                }
                lowest_layer_z_index = layer_to_enable;
            }
            if (lowest_layer_z_index) |lowest_layer_z_index_nonull| {
                lowest_layer_z_index_nonull.is_active = true;
            }
        }
    }
};
