const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const Layer = @import("layer.zig").Layer;
const WindowManager = @import("window_manager.zig").WindowManager;
const ButtonPage = @import("button_page.zig").ButtonPage;
const ButtonLayer = @import("button_layer.zig").ButtonLayer;
const WordMenu = @import("word_menu.zig").WordMenu;
const V2 = @import("v2.zig").V2;
const JsonManager = @import("json_manager.zig").JsonManager;

pub const AnimeTalkPage = struct {
    pub fn draw(layer: *Layer, window: *WindowManager) !void {
        if (window.pos_cam[0] != ButtonPage.size[0] * -3) //skip draw if wrong page.
            return;

        // --- ligne 1.

        //draw word background name layer.
        var rect_bg_name: c.SDL_Rect = .{
            .x = 0,
            .y = @as(i16, @intCast(layer.z_index * 3 + 4)) * ButtonLayer.size[1] * -1,
            .w = ButtonPage.size[0] - ButtonLayer.size[1] * 2,
            .h = ButtonPage.size[1],
        };
        rect_bg_name.y -= window.pos_cam[1]; //scrolling replacement.
        const rect_bg_name_crop: c.SDL_Rect = .{
            .x = 0,
            .y = 0,
            .w = ButtonPage.size[0] - ButtonLayer.size[1] * 2,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            ButtonLayer.texture,
            &rect_bg_name_crop,
            &rect_bg_name,
        );

        //draw the name layer.
        const rect_text: c.SDL_Rect = .{
            .x = rect_bg_name.x + @divFloor(ButtonLayer.size[1], 4),
            .y = rect_bg_name.y + @divFloor(ButtonLayer.size[1], 4),
            .w = ButtonLayer.size[0] - ButtonLayer.size[1] * 2 - @divFloor(ButtonLayer.size[1], 2),
            .h = @divFloor(ButtonLayer.size[1], 2),
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            layer.texture_text,
            null,
            &rect_text,
        );

        // --- ligne 2.

        //draw word anime start.
        const rect_animestart: c.SDL_Rect = .{
            .x = 0,
            .y = rect_bg_name.y + ButtonPage.size[1],
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(10),
            &rect_animestart,
        );

        //draw var anime start.
        const width_var_animestart = 50;
        const rect_var_animestart: c.SDL_Rect = .{
            .x = ButtonPage.size[0] - ButtonPage.size[1] - width_var_animestart,
            .y = rect_animestart.y,
            .w = width_var_animestart,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            layer.talking_anime_start.getTexture(),
            null,
            &rect_var_animestart,
        );

        //draw button anime start.
        const rect_button_animestart: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1],
            .y = rect_animestart.y,
            .w = ButtonLayer.size[1],
            .h = ButtonPage.size[1],
        };
        const rect_button_animestart_crop: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1] * 2,
            .y = 0,
            .w = ButtonLayer.size[1],
            .h = ButtonLayer.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            ButtonLayer.texture,
            &rect_button_animestart_crop,
            &rect_button_animestart,
        );

        // --- ligne 3.

        //draw word anime end.
        const rect_animeend: c.SDL_Rect = .{
            .x = 0,
            .y = rect_bg_name.y + ButtonPage.size[1] * 2,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(11),
            &rect_animeend,
        );

        //draw var anime end.
        const rect_var_animeend: c.SDL_Rect = .{
            .x = ButtonPage.size[0] - ButtonPage.size[1] - width_var_animestart,
            .y = rect_animeend.y,
            .w = width_var_animestart,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            layer.talking_anime_end.getTexture(),
            null,
            &rect_var_animeend,
        );

        //draw button anime end.
        const rect_button_animeend: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1],
            .y = rect_animeend.y,
            .w = ButtonLayer.size[1],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            ButtonLayer.texture,
            &rect_button_animestart_crop,
            &rect_button_animeend,
        );
    }

    pub fn drawFix(window: *WindowManager) !void {
        if (window.pos_cam[0] != ButtonPage.size[0] * -3) //skip draw if wrong page.
            return;

        // --- ligne 4. (span size talking)

        //draw word talking.
        const rect_talking: c.SDL_Rect = .{
            .x = 0,
            .y = 0 - window.pos_cam[1],
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(12),
            &rect_talking,
        );

        //draw var talking.
        const width_var_talking = 50;
        const rect_var_talking: c.SDL_Rect = .{
            .x = ButtonPage.size[0] - ButtonPage.size[1] - width_var_talking,
            .y = rect_talking.y,
            .w = width_var_talking,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            JsonManager.data_params.talking_anime_span_size.getTexture(),
            null,
            &rect_var_talking,
        );

        //draw button talking.
        const rect_button_talking: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1],
            .y = rect_talking.y,
            .w = ButtonLayer.size[1],
            .h = ButtonPage.size[1],
        };
        const rect_button_talking_crop: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1] * 2,
            .y = 0,
            .w = ButtonLayer.size[1],
            .h = ButtonLayer.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            ButtonLayer.texture,
            &rect_button_talking_crop,
            &rect_button_talking,
        );
    }

    pub fn click(pos_click: V2, pos_cam: V2, layers: *std.ArrayList(Layer)) bool {
        if (pos_cam[0] != ButtonPage.size[0] * -3)
            return false;

        const pos_click_world: V2 = .{
            pos_click[0] + pos_cam[0],
            pos_click[1] + pos_cam[1],
        };

        for (layers.items) |*layer| {
            const pos_button_animestart: V2 = .{
                (ButtonLayer.size[0] - ButtonLayer.size[1]) + pos_cam[0],
                (@as(i16, @intCast(layer.z_index * 3 + 3)) * ButtonLayer.size[1] * -1), //+ pos_cam[1]
            };
            if (pos_button_animestart[0] < pos_click_world[0] and
                pos_button_animestart[0] + ButtonLayer.size[1] > pos_click_world[0] and
                pos_button_animestart[1] < pos_click_world[1] and
                pos_button_animestart[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on button anime start (add or sub).

                const is_arrow_up = (pos_button_animestart[1] + @divFloor(ButtonLayer.size[1], 2) > pos_click_world[1]);
                if (is_arrow_up) {
                    layer.talking_anime_start.set(std.math.clamp((layer.talking_anime_start.get() orelse 0) + 1, 0, 5000));
                } else {
                    layer.talking_anime_start.set(std.math.clamp((layer.talking_anime_start.get() orelse 0) -| 1, 0, 5000));
                }

                return true;
            }

            const pos_button_animestart_num: V2 = .{
                pos_button_animestart[0] - ButtonLayer.size[1],
                pos_button_animestart[1], //+ pos_cam[1]
            };
            if (pos_button_animestart_num[0] < pos_click_world[0] and
                pos_button_animestart_num[0] + ButtonLayer.size[1] > pos_click_world[0] and
                pos_button_animestart_num[1] < pos_click_world[1] and
                pos_button_animestart_num[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on button anime start (number).

                layer.talking_anime_start.set(if (layer.talking_anime_start.get() == null) 0 else null);

                return true;
            }

            const pos_button_animeend: V2 = .{
                pos_button_animestart[0],
                pos_button_animestart[1] + ButtonLayer.size[1],
            };
            if (pos_button_animeend[0] < pos_click_world[0] and
                pos_button_animeend[0] + ButtonLayer.size[1] > pos_click_world[0] and
                pos_button_animeend[1] < pos_click_world[1] and
                pos_button_animeend[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on button anime end (add or sub).

                const is_arrow_up = (pos_button_animeend[1] + @divFloor(ButtonLayer.size[1], 2) > pos_click_world[1]);
                if (is_arrow_up) {
                    layer.talking_anime_end.set(std.math.clamp((layer.talking_anime_end.get() orelse 0) + 1, 0, 5000));
                } else {
                    layer.talking_anime_end.set(std.math.clamp((layer.talking_anime_end.get() orelse 0) -| 1, 0, 5000));
                }

                return true;
            }

            const pos_button_animeend_num: V2 = .{
                pos_button_animeend[0] - ButtonLayer.size[1],
                pos_button_animeend[1],
            };
            if (pos_button_animeend_num[0] < pos_click_world[0] and
                pos_button_animeend_num[0] + ButtonLayer.size[1] > pos_click_world[0] and
                pos_button_animeend_num[1] < pos_click_world[1] and
                pos_button_animeend_num[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on button anime end (number).

                layer.talking_anime_end.set(if (layer.talking_anime_end.get() == null) 0 else null);

                return true;
            }
        }

        const pos_button_talking: V2 = .{
            (ButtonLayer.size[0] - ButtonLayer.size[1]) + pos_cam[0],
            0,
        };
        if (pos_button_talking[0] < pos_click_world[0] and
            pos_button_talking[0] + ButtonLayer.size[1] > pos_click_world[0] and
            pos_button_talking[1] < pos_click_world[1] and
            pos_button_talking[1] + ButtonLayer.size[1] > pos_click_world[1])
        {
            //click on button talking (add or sub).

            const is_arrow_up = (pos_button_talking[1] + @divFloor(ButtonLayer.size[1], 2) > pos_click_world[1]);
            if (is_arrow_up) {
                JsonManager.data_params.talking_anime_span_size.set(std.math.clamp(JsonManager.data_params.talking_anime_span_size.get() + 1, 0, 5000));
            } else {
                JsonManager.data_params.talking_anime_span_size.set(std.math.clamp(JsonManager.data_params.talking_anime_span_size.get() -| 1, 0, 5000));
            }

            return true;
        }

        return false;
    }
};
