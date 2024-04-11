const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const ButtonPage = @import("button_page.zig").ButtonPage;
const WindowManager = @import("window_manager.zig").WindowManager;
const WordMenu = @import("word_menu.zig").WordMenu;
const JsonManager = @import("json_manager.zig").JsonManager;
const V2 = @import("v2.zig").V2;
const FpsNorme = @import("enum/fps_norme.zig");
const Update = @import("update.zig").Update;
const ButtonLayer = @import("button_layer.zig").ButtonLayer;
const Layer = @import("layer.zig").Layer;

pub const WindowPage = struct {
    pub fn draw(window: *WindowManager, is_edit_menu_maked: *bool) !void {
        if (window.pos_cam[0] != ButtonPage.size[0] * 2) //skip draw if wrong page.
            return;

        //draw word zoom.
        const rect_zoom: c.SDL_Rect = .{
            .x = 0,
            .y = 0,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(1),
            &rect_zoom,
        );

        //draw button zoom.
        const rect_button_zoom: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 1,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        const error_code_button_zoom = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonPage.texture,
            null,
            &rect_button_zoom, //pos to draw.
        );
        if (error_code_button_zoom != 0) { //error c to zig.
            return error.renderCopy;
        }

        //draw var zoom.
        const reduce_width_var_zoom = 80;
        const rect_var_zoom: c.SDL_Rect = .{
            .x = rect_button_zoom.x + ButtonPage.size[1] + @divFloor(reduce_width_var_zoom, 2),
            .y = rect_button_zoom.y,
            .w = ButtonPage.size[0] - ButtonPage.size[1] * 2 - reduce_width_var_zoom,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            JsonManager.data_params.zoom.getTexture(),
            null,
            &rect_var_zoom,
        );

        // ---

        //draw word fps.
        const rect_fps: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 2,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(2),
            &rect_fps,
        );

        //draw button fps.
        const rect_button_fps: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 3,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        const error_code_button_fps = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonPage.texture,
            null,
            &rect_button_fps, //pos to draw.
        );
        if (error_code_button_fps != 0) { //error c to zig.
            return error.renderCopy;
        }

        //draw var zoom.
        const reduce_width_var_fps = 80;
        const rect_var_fps: c.SDL_Rect = .{
            .x = rect_button_fps.x + ButtonPage.size[1] + @divFloor(reduce_width_var_fps, 2),
            .y = rect_button_fps.y,
            .w = ButtonPage.size[0] - ButtonPage.size[1] * 2 - reduce_width_var_fps,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            JsonManager.data_params.fps.getTexture(),
            null,
            &rect_var_fps,
        );

        // ---

        //draw word readfile.
        const rect_readfile: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 4,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(3),
            &rect_readfile,
        );

        //draw button center readfile.
        const rect_var_readfile: c.SDL_Rect = .{
            .x = @divFloor(ButtonPage.size[0], 2) - @divFloor(ButtonLayer.size[1], 2),
            .y = ButtonPage.size[1] * 5,
            .w = ButtonLayer.size[1],
            .h = ButtonLayer.size[1],
        };
        const rect_color_readfile: c.SDL_Rect = .{
            .x = rect_var_readfile.x + @divFloor(ButtonLayer.size[1], 4),
            .y = rect_var_readfile.y + @divFloor(ButtonLayer.size[1], 4),
            .w = @divFloor(ButtonLayer.size[1], 2),
            .h = @divFloor(ButtonLayer.size[1], 2),
        };
        _ = c.SDL_SetRenderDrawColor(
            window.renderer,
            if (JsonManager.data_params.read_file_accesory) 102 else 255, //green or red.
            if (JsonManager.data_params.read_file_accesory) 255 else 102,
            102,
            255,
        );
        _ = c.SDL_RenderFillRect( //draw rect (color active).
            window.renderer,
            &rect_color_readfile,
        );
        const rect_var_readfile_crop: c.SDL_Rect = .{
            .x = ButtonLayer.size[0] - ButtonLayer.size[1],
            .y = 0,
            .w = ButtonLayer.size[1],
            .h = ButtonLayer.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            ButtonLayer.texture,
            &rect_var_readfile_crop,
            &rect_var_readfile,
        );

        // ---

        //draw word save.
        const rect_save: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 6,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(4),
            &rect_save,
        );

        //draw button center save.
        const rect_var_save: c.SDL_Rect = .{
            .x = rect_var_readfile.x,
            .y = ButtonPage.size[1] * 7,
            .w = ButtonLayer.size[1],
            .h = ButtonLayer.size[1],
        };
        const rect_color_save: c.SDL_Rect = .{
            .x = rect_var_save.x + @divFloor(ButtonLayer.size[1], 4),
            .y = rect_var_save.y + @divFloor(ButtonLayer.size[1], 4),
            .w = @divFloor(ButtonLayer.size[1], 2),
            .h = @divFloor(ButtonLayer.size[1], 2),
        };
        _ = c.SDL_SetRenderDrawColor(
            window.renderer,
            if (is_edit_menu_maked.*) 255 else 102, //green or red.
            if (is_edit_menu_maked.*) 102 else 255,
            102,
            255,
        );
        _ = c.SDL_RenderFillRect( //draw rect (color active).
            window.renderer,
            &rect_color_save,
        );
        _ = c.SDL_RenderCopy(
            window.renderer,
            ButtonLayer.texture,
            &rect_var_readfile_crop,
            &rect_var_save,
        );
    }

    pub fn click(pos_click: V2, pos_cam: V2, window_png_tuber: *WindowManager, size_base_layer: V2, is_edit_menu_maked: *bool, layers: *std.ArrayList(Layer)) bool {
        if (pos_cam[0] != ButtonPage.size[0] * 2)
            return false;

        //button substract zoom.
        const pos_button_zoom_substract: V2 = .{
            0,
            ButtonPage.size[1] * 1,
        };
        if (pos_button_zoom_substract[0] < pos_click[0] and
            pos_button_zoom_substract[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_zoom_substract[1] < pos_click[1] and
            pos_button_zoom_substract[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on substract button.

            JsonManager.data_params.zoom.set(std.math.clamp(JsonManager.data_params.zoom.get() - 0.1, 0.1, 6.0));

            //do resise window.
            window_png_tuber.resize(.{
                @as(i16, @intFromFloat(@as(f16, @floatFromInt(size_base_layer[0])) * JsonManager.data_params.zoom.get())),
                @as(i16, @intFromFloat(@as(f16, @floatFromInt(size_base_layer[1])) * JsonManager.data_params.zoom.get())),
            });

            is_edit_menu_maked.* = true;

            return true;
        }

        //button add zoom.
        const pos_button_zoom_add: V2 = .{
            ButtonPage.size[0] - ButtonPage.size[1],
            ButtonPage.size[1] * 1,
        };
        if (pos_button_zoom_add[0] < pos_click[0] and
            pos_button_zoom_add[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_zoom_add[1] < pos_click[1] and
            pos_button_zoom_add[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on add button.

            JsonManager.data_params.zoom.set(std.math.clamp(JsonManager.data_params.zoom.get() + 0.1, 0.1, 6.0));

            //do resise window.
            window_png_tuber.resize(.{
                @as(i16, @intFromFloat(@as(f16, @floatFromInt(size_base_layer[0])) * JsonManager.data_params.zoom.get())),
                @as(i16, @intFromFloat(@as(f16, @floatFromInt(size_base_layer[1])) * JsonManager.data_params.zoom.get())),
            });

            is_edit_menu_maked.* = true;

            return true;
        }

        // ---

        //button substract fps.
        const pos_button_fps_substract: V2 = .{
            0,
            ButtonPage.size[1] * 3,
        };
        if (pos_button_fps_substract[0] < pos_click[0] and
            pos_button_fps_substract[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_fps_substract[1] < pos_click[1] and
            pos_button_fps_substract[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on substract button.

            JsonManager.data_params.fps.set(FpsNorme.editFPS(JsonManager.data_params.fps.get(), -1));

            Update.eval_milisec_by_frame(JsonManager.data_params.fps.get());

            is_edit_menu_maked.* = true;

            return true;
        }

        //button add fps.
        const pos_button_fps_add: V2 = .{
            ButtonPage.size[0] - ButtonPage.size[1],
            ButtonPage.size[1] * 3,
        };
        if (pos_button_fps_add[0] < pos_click[0] and
            pos_button_fps_add[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_fps_add[1] < pos_click[1] and
            pos_button_fps_add[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on add button.

            JsonManager.data_params.fps.set(FpsNorme.editFPS(JsonManager.data_params.fps.get(), 1));

            Update.eval_milisec_by_frame(JsonManager.data_params.fps.get());

            is_edit_menu_maked.* = true;

            return true;
        }

        // ---

        //button readfile.
        const pos_button_readfile: V2 = .{
            @divFloor(ButtonPage.size[0], 2) - @divFloor(ButtonLayer.size[1], 2),
            ButtonPage.size[1] * 5,
        };
        if (pos_button_readfile[0] < pos_click[0] and
            pos_button_readfile[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_readfile[1] < pos_click[1] and
            pos_button_readfile[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on button.

            JsonManager.data_params.read_file_accesory = !JsonManager.data_params.read_file_accesory;

            is_edit_menu_maked.* = true;

            return true;
        }

        // ---

        //button save.
        const pos_button_save: V2 = .{
            @divFloor(ButtonPage.size[0], 2) - @divFloor(ButtonLayer.size[1], 2),
            ButtonPage.size[1] * 7,
        };
        if (pos_button_save[0] < pos_click[0] and
            pos_button_save[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_save[1] < pos_click[1] and
            pos_button_save[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on button.

            JsonManager.saveData(layers) catch {
                return true;
            };

            is_edit_menu_maked.* = false;

            return true;
        }

        return false;
    }
};
