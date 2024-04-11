const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const V2 = @import("v2.zig").V2;
const Layer = @import("layer.zig").Layer;
const WindowManager = @import("window_manager.zig").WindowManager;
const ButtonLayer = @import("button_layer.zig").ButtonLayer;
const TalkTypeLayer = @import("enum/talk_type_layer.zig").TalkTypeLayer;
const PropsTypeLayer = @import("enum/props_type_layer.zig").PropsTypeLayer;

pub const ButtonEnum = struct {
    pub var texture: *c.SDL_Texture = undefined; //texture for button.
    pub var size: V2 = .{ 50, 50 }; //size of one logo.

    pub fn init(renderer: *c.SDL_Renderer) !void {
        const path_png = "assets/menu/buttonEnum.png";

        const file = try std.fs.cwd().openFile(
            path_png,
            .{},
        );
        defer file.close();

        const surface = c.IMG_Load(@ptrCast(path_png)) orelse { //build a surface for texture.
            std.log.err("error to load surface of file : {s}", .{path_png});
            std.log.err("{s}", .{c.SDL_GetError()});
            return error.errorButtonEnumSurfaceSDL; //skip if one file can't get texture.
        };
        defer c.SDL_FreeSurface(surface);

        ButtonEnum.texture = c.SDL_CreateTextureFromSurface(renderer, surface) orelse { //get texture frome file png.
            std.log.err("error to load texture of file : {s}", .{path_png});
            std.log.err("{s}", .{c.SDL_GetError()});
            return error.errorButtonEnumTextureSDL; //skip if one file can't get texture.
        };
    }

    pub fn deinit() void {
        c.SDL_DestroyTexture(ButtonEnum.texture);
    }

    pub fn draw(layer: *Layer, window: *WindowManager) !void {
        if (window.pos_cam[0] != ButtonLayer.size[0] * -1) //skip draw if wrong page.
            return;

        //position.
        var destination_rect: c.SDL_Rect = .{
            .x = 0, //pos to draw.
            .y = @as(i16, @intCast(layer.z_index)) * ButtonLayer.size[1] * -1,
            .w = ButtonLayer.size[0] - ButtonEnum.size[0] * 2, //size texture.
            .h = ButtonLayer.size[1],
        };
        //destination_rect.x -= window.pos_cam[0]; //scrolling replacement.
        destination_rect.y -= window.pos_cam[1]; //scrolling replacement.

        //draw texture button background.
        const rect_part_texture: c.SDL_Rect = .{
            .x = 0,
            .y = 0,
            .w = destination_rect.w,
            .h = destination_rect.h,
        };
        const error_code = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonLayer.texture,
            &rect_part_texture, //part texture draw (all).
            &destination_rect, //pos to draw.
        );
        if (error_code != 0) { //error c to zig.
            return error.renderCopy;
        }

        //draw the name.
        const rect_text: c.SDL_Rect = .{
            .x = destination_rect.x + @divFloor(ButtonLayer.size[1], 4),
            .y = destination_rect.y + @divFloor(ButtonLayer.size[1], 4),
            .w = ButtonLayer.size[0] - ButtonLayer.size[1] * 2 - @divFloor(ButtonLayer.size[1], 2),
            .h = @divFloor(ButtonLayer.size[1], 2),
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            layer.texture_text,
            null,
            &rect_text,
        );

        //draw logo talk type.
        const destination_rect_logo_talk: c.SDL_Rect = .{
            .x = destination_rect.x + destination_rect.w, //pos to draw.
            .y = destination_rect.y,
            .w = ButtonEnum.size[0], //size texture.
            .h = ButtonEnum.size[1],
        };
        const rect_part_texture_logo_talk: c.SDL_Rect = .{
            .x = @intFromEnum(layer.talk_type) * ButtonEnum.size[0], //pos to draw.
            .y = 0,
            .w = ButtonEnum.size[0], //size texture.
            .h = ButtonEnum.size[1],
        };
        const error_code_logo_talk = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonEnum.texture,
            &rect_part_texture_logo_talk, //part texture draw (all).
            &destination_rect_logo_talk, //pos to draw.
        );
        if (error_code_logo_talk != 0) { //error c to zig.
            return error.renderCopy;
        }

        //draw logo props type.
        const destination_rect_logo_props: c.SDL_Rect = .{
            .x = destination_rect_logo_talk.x + ButtonEnum.size[0], //pos to draw.
            .y = destination_rect.y,
            .w = ButtonEnum.size[0], //size texture.
            .h = ButtonEnum.size[1],
        };
        const rect_part_texture_logo_props: c.SDL_Rect = .{
            .x = @intFromEnum(layer.props_type) * ButtonEnum.size[0], //pos to draw.
            .y = ButtonEnum.size[1],
            .w = ButtonEnum.size[0], //size texture.
            .h = ButtonEnum.size[1],
        };
        const error_code_logo_props = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonEnum.texture,
            &rect_part_texture_logo_props, //part texture draw (all).
            &destination_rect_logo_props, //pos to draw.
        );
        if (error_code_logo_props != 0) { //error c to zig.
            return error.renderCopy;
        }
    }

    pub fn click(pos_click: V2, layers: *std.ArrayList(Layer), pos_cam: V2) bool {
        if (pos_cam[0] != ButtonLayer.size[0] * -1)
            return false;

        const pos_click_world: V2 = .{
            pos_click[0] + pos_cam[0],
            pos_click[1] + pos_cam[1],
        };

        for (layers.items) |*layer| {
            const pos_layer_button: V2 = .{
                ButtonLayer.size[0] - (ButtonLayer.size[1] * 2) + pos_cam[0],
                @as(i16, @intCast(layer.z_index)) * ButtonLayer.size[1] * -1,
            };

            if (pos_layer_button[0] < pos_click_world[0] and
                pos_layer_button[0] + ButtonLayer.size[1] > pos_click_world[0] and
                pos_layer_button[1] < pos_click_world[1] and
                pos_layer_button[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on first button.

                //take next enum.
                const enum_int = @intFromEnum(layer.talk_type) + 1;
                const enum_clamp = enum_int % @intFromEnum(TalkTypeLayer.last_enum_value_not_to_use);
                layer.talk_type = @enumFromInt(enum_clamp);

                return true;
            } else if (pos_layer_button[0] + ButtonLayer.size[1] < pos_click_world[0] and
                pos_layer_button[0] + ButtonLayer.size[1] * 2 > pos_click_world[0] and
                pos_layer_button[1] < pos_click_world[1] and
                pos_layer_button[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on second button.

                //take next enum.
                const enum_int = @intFromEnum(layer.props_type) + 1;
                const enum_clamp = enum_int % @intFromEnum(PropsTypeLayer.last_enum_value_not_to_use);
                layer.props_type = @enumFromInt(enum_clamp);

                return true;
            }
        }
        return false;
    }
};
