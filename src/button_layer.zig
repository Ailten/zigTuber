const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const V2 = @import("v2.zig").V2;
const Layer = @import("layer.zig").Layer;
const WindowManager = @import("window_manager.zig").WindowManager;

pub const ButtonLayer = struct {
    pub var texture: *c.SDL_Texture = undefined; //texture for button.
    pub var size: V2 = undefined;

    pub fn init(renderer: *c.SDL_Renderer) !void {
        const path_png = "assets/menu/buttonLayer.png";

        const file = try std.fs.cwd().openFile(
            path_png,
            .{},
        );
        defer file.close();

        const surface = c.IMG_Load(@ptrCast(path_png)) orelse { //build a surface for texture.
            std.log.err("error to load surface of file : {s}", .{path_png});
            std.log.err("{s}", .{c.SDL_GetError()});
            return error.errorButtonLayerSurfaceSDL; //skip if one file can't get texture.
        };
        defer c.SDL_FreeSurface(surface);

        ButtonLayer.texture = c.SDL_CreateTextureFromSurface(renderer, surface) orelse { //get texture frome file png.
            std.log.err("error to load texture of file : {s}", .{path_png});
            std.log.err("{s}", .{c.SDL_GetError()});
            return error.errorButtonLayerTextureSDL; //skip if one file can't get texture.
        };

        var x_c_int: c_int = undefined; //get size of texture.
        var y_c_int: c_int = undefined;
        _ = c.SDL_QueryTexture( //feed var c_int.
            ButtonLayer.texture,
            null,
            null,
            &x_c_int,
            &y_c_int,
        );

        ButtonLayer.size = .{ //size V2 from texture.
            @intCast(x_c_int),
            @intCast(y_c_int),
        };
    }

    pub fn deinit() void {
        c.SDL_DestroyTexture(ButtonLayer.texture);
    }

    pub fn draw(layer: *Layer, window: *WindowManager) !void { //renderer: *c.SDL_Renderer
        if (window.pos_cam[0] != 0) //skip draw if wrong page.
            return;

        //position.
        var destination_rect: c.SDL_Rect = c.SDL_Rect{
            .x = 0, //pos to draw.
            .y = @as(i16, @intCast(layer.z_index)) * ButtonLayer.size[1] * -1,
            .w = ButtonLayer.size[0], //size texture.
            .h = ButtonLayer.size[1],
        };
        //destination_rect.x -= window.pos_cam[0]; //scrolling replacement.
        destination_rect.y -= window.pos_cam[1]; //scrolling replacement.

        //draw rect color active/or not.
        _ = c.SDL_SetRenderDrawColor(
            window.renderer,
            if (layer.is_active) 102 else 255, //green or red.
            if (layer.is_active) 255 else 102,
            102,
            255,
        );
        const rect_active: c.SDL_Rect = .{
            .x = destination_rect.x + ButtonLayer.size[0] - ButtonLayer.size[1] + 10,
            .y = destination_rect.y + 10,
            .w = ButtonLayer.size[1] - 20,
            .h = ButtonLayer.size[1] - 20,
        };
        _ = c.SDL_RenderFillRect( //draw point (color active).
            window.renderer,
            &rect_active,
        );

        //draw texture button background.
        const error_code = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonLayer.texture,
            null, //part texture draw (all).
            &destination_rect, //pos to draw.
        );
        if (error_code != 0) { //error c to zig.
            return error.renderCopy;
        }

        //init texture_text.
        if (layer.texture_text == null) {
            const font: *c.TTF_Font = c.TTF_OpenFont("assets/menu/font/emmasophia.ttf", @divFloor(ButtonLayer.size[1], 4)) orelse {
                std.log.err("error to open font TTF : {s}", .{c.TTF_GetError()});
                return error.errorTTFopenFont;
            };
            const color_text: c.SDL_Color = .{
                .r = 0,
                .g = 0,
                .b = 0,
                .a = 255,
            };

            //std.debug.print(" --- name : {s}\n", .{self.name.items});

            while (true) {
                if (layer.name.items.len >= 20)
                    break;
                try layer.name.append(' ');
            }
            try layer.name.append(0);

            const surface_text = c.TTF_RenderText_Solid( //Blended.
                font,
                @ptrCast(layer.name.items),
                color_text,
            );
            defer c.SDL_FreeSurface(surface_text);

            while (true) {
                if (layer.name.items.len == 0)
                    break;
                if (layer.name.items[layer.name.items.len - 1] == 0 or layer.name.items[layer.name.items.len - 1] == ' ') {
                    _ = layer.name.pop();
                } else {
                    break;
                }
            }
            if (layer.name.items.len != 0 and layer.name.items[layer.name.items.len - 1] == 0)
                _ = layer.name.pop();

            layer.texture_text = c.SDL_CreateTextureFromSurface(window.renderer, surface_text) orelse {
                std.log.err("error in CreateTextureFromSurface", .{});
                return error.errorCreateTextureSDL;
            };
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
    }

    pub fn click(pos_click: V2, layers: *std.ArrayList(Layer), pos_cam: V2) bool {
        if (pos_cam[0] != 0)
            return false;

        const pos_click_world: V2 = .{
            pos_click[0] + pos_cam[0],
            pos_click[1] + pos_cam[1],
        };

        for (layers.items) |*layer| {
            const pos_layer_button: V2 = .{
                ButtonLayer.size[0] - (ButtonLayer.size[1] * 2),
                @as(i16, @intCast(layer.z_index)) * ButtonLayer.size[1] * -1,
            };

            if (pos_layer_button[0] < pos_click_world[0] and
                pos_layer_button[0] + ButtonLayer.size[1] > pos_click_world[0] and
                pos_layer_button[1] < pos_click_world[1] and
                pos_layer_button[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on first button.
                const is_arrow_up = (pos_layer_button[1] + @divFloor(ButtonLayer.size[1], 2) > pos_click_world[1]);

                if ((is_arrow_up and layer.z_index == layers.items.len - 1) or
                    (!is_arrow_up and layer.z_index == 0))
                    return true; //over range swipe.

                var index_layer_b = layer.z_index; //swipe z_index.   //+ if (is_arrow_up) -1 else 1
                if (is_arrow_up) {
                    index_layer_b = index_layer_b + 1;
                } else {
                    index_layer_b = index_layer_b - 1;
                }
                const z_index_layer_b = layers.items[index_layer_b].z_index;
                layers.items[index_layer_b].z_index = layer.z_index;
                layer.z_index = z_index_layer_b;

                //re-sort.
                std.mem.sort( //order by z index.
                    Layer,
                    layers.items,
                    void{},
                    Layer.lessThan,
                );

                return true;
            }

            if (pos_layer_button[0] + ButtonLayer.size[1] < pos_click_world[0] and
                pos_layer_button[0] + ButtonLayer.size[1] * 2 > pos_click_world[0] and
                pos_layer_button[1] < pos_click_world[1] and
                pos_layer_button[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on second button.
                layer.is_active = !layer.is_active; //swipe is active.

                if (layer.is_active) { //if active, disable the layer active with same type.
                    for (layers.items) |*layer_to_disable| {
                        if (layer_to_disable.props_type != layer.props_type)
                            continue;
                        if (layer_to_disable.props_type == .no_props or
                            layer_to_disable.props_type == .props or
                            layer_to_disable.props_type == .mouth_talking)
                            continue;
                        if (layer_to_disable.z_index == layer.z_index)
                            continue;

                        layer_to_disable.is_active = false;
                    }
                } else if (layer.props_type == .eyes or
                    layer.props_type == .mouth or
                    layer.props_type == .hat)
                { //if disable layer and it's a layer need every tipe one type active, active the same type lowest index.
                    var lowest_layer_z_index: ?*Layer = null;
                    for (layers.items) |*layer_to_enable| {
                        if (layer_to_enable.props_type != layer.props_type)
                            continue;
                        if (layer_to_enable.z_index >= layer.z_index)
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

                return true;
            }
        }
        return false;
    }
};
