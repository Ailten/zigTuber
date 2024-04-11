const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const WindowManager = @import("window_manager.zig").WindowManager;
const ButtonPage = @import("button_page.zig").ButtonPage;
const WordMenu = @import("word_menu.zig").WordMenu;
const JsonManager = @import("json_manager.zig").JsonManager;
const V2 = @import("v2.zig").V2;

pub const AnimePage = struct {
    pub fn draw(window: *WindowManager) !void {
        if (window.pos_cam[0] != ButtonPage.size[0] * 3) //skip draw if wrong page.
            return;

        //draw word speedanime.
        const rect_speedanime: c.SDL_Rect = .{
            .x = 0,
            .y = 0,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(5),
            &rect_speedanime,
        );

        //draw button speedanime.
        const rect_button_speedanime: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 1,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        const error_code_button_speedanime = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonPage.texture,
            null,
            &rect_button_speedanime, //pos to draw.
        );
        if (error_code_button_speedanime != 0) { //error c to zig.
            return error.renderCopy;
        }

        //draw var speedanime.
        const reduce_width_var_speedanime = 80;
        const rect_var_speedanime: c.SDL_Rect = .{
            .x = rect_button_speedanime.x + ButtonPage.size[1] + @divFloor(reduce_width_var_speedanime, 2),
            .y = rect_button_speedanime.y,
            .w = ButtonPage.size[0] - ButtonPage.size[1] * 2 - reduce_width_var_speedanime,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            JsonManager.data_params.speed_anime.getTexture(),
            null,
            &rect_var_speedanime,
        );

        // ---

        //draw word speedtalk.
        const rect_speedtalk: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 2,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(6),
            &rect_speedtalk,
        );

        //draw button speedtalk.
        const rect_button_speedtalk: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 3,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        const error_code_button_speedtalk = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonPage.texture,
            null,
            &rect_button_speedtalk, //pos to draw.
        );
        if (error_code_button_speedtalk != 0) { //error c to zig.
            return error.renderCopy;
        }

        //draw var speedtalk.
        const reduce_width_var_speedtalk = 80;
        const rect_var_speedtalk: c.SDL_Rect = .{
            .x = rect_button_speedtalk.x + ButtonPage.size[1] + @divFloor(reduce_width_var_speedtalk, 2),
            .y = rect_button_speedtalk.y,
            .w = ButtonPage.size[0] - ButtonPage.size[1] * 2 - reduce_width_var_speedtalk,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            JsonManager.data_params.speed_talking.getTexture(),
            null,
            &rect_var_speedtalk,
        );

        // ---

        //draw word jumptalk.
        const rect_jumptalk: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 4,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(7),
            &rect_jumptalk,
        );

        //draw button jumptalk.
        const rect_button_jumptalk: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 5,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        const error_code_button_jumptalk = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonPage.texture,
            null,
            &rect_button_jumptalk, //pos to draw.
        );
        if (error_code_button_jumptalk != 0) { //error c to zig.
            return error.renderCopy;
        }

        //draw var jumptalk.
        const reduce_width_var_jumptalk = 80;
        const rect_var_jumptalk: c.SDL_Rect = .{
            .x = rect_button_jumptalk.x + ButtonPage.size[1] + @divFloor(reduce_width_var_jumptalk, 2),
            .y = rect_button_jumptalk.y,
            .w = ButtonPage.size[0] - ButtonPage.size[1] * 2 - reduce_width_var_jumptalk,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            JsonManager.data_params.jump_high_when_talking.getTexture(),
            null,
            &rect_var_jumptalk,
        );

        // ---

    }

    pub fn click(pos_click: V2, pos_cam: V2) bool {
        if (pos_cam[0] != ButtonPage.size[0] * 3) //skip draw if wrong page.
            return false;

        //button substract speedanime.
        const pos_button_speedanime_substract: V2 = .{
            0,
            ButtonPage.size[1] * 1,
        };
        if (pos_button_speedanime_substract[0] < pos_click[0] and
            pos_button_speedanime_substract[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_speedanime_substract[1] < pos_click[1] and
            pos_button_speedanime_substract[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on substract button.

            JsonManager.data_params.speed_anime.set(std.math.clamp(JsonManager.data_params.speed_anime.get() - 0.1, 0.1, 10.0));

            return true;
        }

        //button add speedanime.
        const pos_button_speedanime_add: V2 = .{
            ButtonPage.size[0] - ButtonPage.size[1],
            ButtonPage.size[1] * 1,
        };
        if (pos_button_speedanime_add[0] < pos_click[0] and
            pos_button_speedanime_add[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_speedanime_add[1] < pos_click[1] and
            pos_button_speedanime_add[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on add button.

            JsonManager.data_params.speed_anime.set(std.math.clamp(JsonManager.data_params.speed_anime.get() + 0.1, 0.1, 10.0));

            return true;
        }

        // ---

        //button substract speedtalk.
        const pos_button_speedtalk_substract: V2 = .{
            0,
            ButtonPage.size[1] * 3,
        };
        if (pos_button_speedtalk_substract[0] < pos_click[0] and
            pos_button_speedtalk_substract[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_speedtalk_substract[1] < pos_click[1] and
            pos_button_speedtalk_substract[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on substract button.

            JsonManager.data_params.speed_talking.set(std.math.clamp(JsonManager.data_params.speed_talking.get() - 0.1, 0.1, 10.0));

            return true;
        }

        //button add speedtalk.
        const pos_button_speedtalk_add: V2 = .{
            ButtonPage.size[0] - ButtonPage.size[1],
            ButtonPage.size[1] * 3,
        };
        if (pos_button_speedtalk_add[0] < pos_click[0] and
            pos_button_speedtalk_add[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_speedtalk_add[1] < pos_click[1] and
            pos_button_speedtalk_add[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on add button.

            JsonManager.data_params.speed_talking.set(std.math.clamp(JsonManager.data_params.speed_talking.get() + 0.1, 0.1, 10.0));

            return true;
        }

        // ---

        //button substract jumptalk.
        const pos_button_jumptalk_substract: V2 = .{
            0,
            ButtonPage.size[1] * 5,
        };
        if (pos_button_jumptalk_substract[0] < pos_click[0] and
            pos_button_jumptalk_substract[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_jumptalk_substract[1] < pos_click[1] and
            pos_button_jumptalk_substract[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on substract button.

            JsonManager.data_params.jump_high_when_talking.set(std.math.clamp(JsonManager.data_params.jump_high_when_talking.get() - 1, 0, 99));

            return true;
        }

        //button add jumptalk.
        const pos_button_jumptalk_add: V2 = .{
            ButtonPage.size[0] - ButtonPage.size[1],
            ButtonPage.size[1] * 5,
        };
        if (pos_button_jumptalk_add[0] < pos_click[0] and
            pos_button_jumptalk_add[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_jumptalk_add[1] < pos_click[1] and
            pos_button_jumptalk_add[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on add button.

            JsonManager.data_params.jump_high_when_talking.set(std.math.clamp(JsonManager.data_params.jump_high_when_talking.get() + 1, 0, 99));

            return true;
        }

        // ---

        return false;
    }
};
