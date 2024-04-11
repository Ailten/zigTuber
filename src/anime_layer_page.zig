const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const WindowManager = @import("window_manager.zig").WindowManager;
const ButtonPage = @import("button_page.zig").ButtonPage;
const Layer = @import("layer.zig").Layer;
const ButtonLayer = @import("button_layer.zig").ButtonLayer;
const WordMenu = @import("word_menu.zig").WordMenu;
const V2 = @import("v2.zig").V2;

pub const AnimeLayerPage = struct {
    pub fn draw(layer: *Layer, window: *WindowManager) !void {
        if (window.pos_cam[0] != ButtonPage.size[0] * -2) //skip draw if wrong page.
            return;

        // --- ligne 1.

        //draw word background name layer.
        var rect_bg_name: c.SDL_Rect = .{
            .x = 0,
            .y = @as(i16, @intCast(layer.z_index * 3 + 2)) * ButtonLayer.size[1] * -1,
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

        //draw word horizontal.
        const rect_hori: c.SDL_Rect = .{
            .x = 0,
            .y = rect_bg_name.y + ButtonPage.size[1],
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(8),
            &rect_hori,
        );

        //draw var horizontal.
        const width_var_hori = 50;
        const rect_var_hori: c.SDL_Rect = .{
            .x = ButtonPage.size[0] - ButtonPage.size[1] - width_var_hori,
            .y = rect_hori.y,
            .w = width_var_hori,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            layer.anime_ineticity_horizontal.getTexture(),
            null,
            &rect_var_hori,
        );

        //draw button horizontal.
        const rect_button_hori: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1],
            .y = rect_hori.y,
            .w = ButtonLayer.size[1],
            .h = ButtonPage.size[1],
        };
        const rect_button_hori_crop: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1] * 2,
            .y = 0,
            .w = ButtonLayer.size[1],
            .h = ButtonLayer.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            ButtonLayer.texture,
            &rect_button_hori_crop,
            &rect_button_hori,
        );

        // --- ligne 3.

        //draw word vertical.
        const rect_verti: c.SDL_Rect = .{
            .x = 0,
            .y = rect_bg_name.y + ButtonPage.size[1] * 2,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(9),
            &rect_verti,
        );

        //draw var vertical.
        const rect_var_verti: c.SDL_Rect = .{
            .x = ButtonPage.size[0] - ButtonPage.size[1] - width_var_hori,
            .y = rect_verti.y,
            .w = width_var_hori,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            layer.anime_ineticity_vertical.getTexture(),
            null,
            &rect_var_verti,
        );

        //draw button vertical.
        const rect_button_verti: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1],
            .y = rect_verti.y,
            .w = ButtonLayer.size[1],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            ButtonLayer.texture,
            &rect_button_hori_crop,
            &rect_button_verti,
        );
    }

    pub fn click(pos_click: V2, pos_cam: V2, layers: *std.ArrayList(Layer)) bool {
        if (pos_cam[0] != ButtonPage.size[0] * -2)
            return false;

        const pos_click_world: V2 = .{
            pos_click[0] + pos_cam[0],
            pos_click[1] + pos_cam[1],
        };

        for (layers.items) |*layer| {
            const pos_button_hori: V2 = .{
                (ButtonLayer.size[0] - ButtonLayer.size[1]) + pos_cam[0],
                (@as(i16, @intCast(layer.z_index * 3 + 1)) * ButtonLayer.size[1] * -1), //+ pos_cam[1]
            };
            if (pos_button_hori[0] < pos_click_world[0] and
                pos_button_hori[0] + ButtonLayer.size[1] > pos_click_world[0] and
                pos_button_hori[1] < pos_click_world[1] and
                pos_button_hori[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on button hori (add or sub).

                const is_arrow_up = (pos_button_hori[1] + @divFloor(ButtonLayer.size[1], 2) > pos_click_world[1]);
                if (is_arrow_up) {
                    layer.anime_ineticity_horizontal.set(std.math.clamp(layer.anime_ineticity_horizontal.get() + 1, -99, 99));
                } else {
                    layer.anime_ineticity_horizontal.set(std.math.clamp(layer.anime_ineticity_horizontal.get() - 1, -99, 99));
                }

                return true;
            }

            const pos_button_verti: V2 = .{
                pos_button_hori[0],
                pos_button_hori[1] + ButtonLayer.size[1],
            };
            if (pos_button_verti[0] < pos_click_world[0] and
                pos_button_verti[0] + ButtonLayer.size[1] > pos_click_world[0] and
                pos_button_verti[1] < pos_click_world[1] and
                pos_button_verti[1] + ButtonLayer.size[1] > pos_click_world[1])
            {
                //click on button verti (add or sub).

                const is_arrow_up = (pos_button_verti[1] + @divFloor(ButtonLayer.size[1], 2) > pos_click_world[1]);
                if (is_arrow_up) {
                    layer.anime_ineticity_vertical.set(std.math.clamp(layer.anime_ineticity_vertical.get() + 1, -99, 99));
                } else {
                    layer.anime_ineticity_vertical.set(std.math.clamp(layer.anime_ineticity_vertical.get() - 1, -99, 99));
                }

                return true;
            }
        }

        return false;
    }
};
