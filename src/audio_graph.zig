const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const V2 = @import("v2.zig").V2;
const WindowManager = @import("window_manager.zig").WindowManager;
const ButtonPage = @import("button_page.zig").ButtonPage;
const AudioManager = @import("miniaudio_wrapper.zig").AudioManager;
const WordMenu = @import("word_menu.zig").WordMenu;

pub const AudioGraph = struct {
    //const size: V2 = .{ 50, 350 };
    const size_decibel: u8 = 20; //number of decibel represent full height graph.

    pub fn draw(window: *WindowManager) !void {
        if (window.pos_cam[0] != ButtonPage.size[0]) //skip draw if wrong page.
            return;

        //pos base graph (fix).
        const rect: c.SDL_Rect = .{
            .x = @divFloor(ButtonPage.size[1], 4), //border pos.
            .y = ButtonPage.size[1] * 8 + @divFloor(ButtonPage.size[1], 4),
            .w = ButtonPage.size[0] - @divFloor(ButtonPage.size[1], 2), //size.
            .h = @divFloor(ButtonPage.size[1], 4),
        };

        //draw base graph.
        const result_set_color = c.SDL_SetRenderDrawColor(
            window.renderer,
            102,
            255,
            102,
            255,
        );
        if (result_set_color != 0) {
            std.log.err("error in setDraColor in AudioGraph.draw", .{});
            return error.errorSetColorSDL;
        }
        const result_draw_rect = c.SDL_RenderFillRect(window.renderer, &rect);
        if (result_draw_rect != 0) {
            std.log.err("error in drawRect in AudioGraph.draw", .{});
            return error.errorSetColorSDL;
        }

        //draw orange rect (zone not talking).
        const width_orange: u16 = @as(u16, @intFromFloat(@as(f16, @floatFromInt(rect.w)) *
            (@as(f16, @floatCast(AudioManager.min_decibel_for_talking)) /
            @as(f16, @floatFromInt(AudioGraph.size_decibel)))));
        const rect_orange: c.SDL_Rect = .{
            .x = rect.x, //border pos.
            .y = rect.y,
            .w = width_orange, //size.
            .h = @divFloor(ButtonPage.size[1], 4),
        };

        const result_set_color_orange = c.SDL_SetRenderDrawColor(
            window.renderer,
            235,
            146,
            52,
            255,
        );
        if (result_set_color_orange != 0) {
            std.log.err("error in setDraColor (orange) in AudioGraph.draw", .{});
            return error.errorSetColorSDL;
        }
        const result_draw_rect_orange = c.SDL_RenderFillRect(window.renderer, &rect_orange);
        if (result_draw_rect_orange != 0) {
            std.log.err("error in drawRect (orange) in AudioGraph.draw", .{});
            return error.errorSetColorSDL;
        }

        //draw rect intencity talk.
        const width_talk: u16 = @as(u16, @intFromFloat(@as(f16, @floatFromInt(rect.w)) *
            (@as(f16, @floatCast(AudioManager.last_decibel_mesure)) /
            @as(f16, @floatFromInt(AudioGraph.size_decibel)))));
        const rect_talk: c.SDL_Rect = .{
            .x = rect.x, //border pos.
            .y = rect.y + @divFloor(ButtonPage.size[1], 4),
            .w = @min(width_talk, rect.w), ////size.
            .h = rect.h,
        };

        const result_set_color_talk = c.SDL_SetRenderDrawColor(
            window.renderer,
            0,
            120,
            0,
            255,
        );
        if (result_set_color_talk != 0) {
            std.log.err("error in setDraColor (talk) in AudioGraph.draw", .{});
            return error.errorSetColorSDL;
        }
        const result_draw_rect_talk = c.SDL_RenderFillRect(window.renderer, &rect_talk);
        if (result_draw_rect_talk != 0) {
            std.log.err("error in drawRect (talk) in AudioGraph.draw", .{});
            return error.errorSetColorSDL;
        }

        //draw input audio mic intencity.
        const destination_rect_button: c.SDL_Rect = .{
            .x = 0,
            .y = ButtonPage.size[1] * 1,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
        const error_code = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonPage.texture,
            null,
            &destination_rect_button, //pos to draw.
        );
        if (error_code != 0) { //error c to zig.
            return error.renderCopy;
        }

        //draw variable intencity mic.
        const reduce_width_var_mic = 80;
        const rect_var_mic: c.SDL_Rect = .{
            .x = destination_rect_button.x + ButtonPage.size[1] + @divFloor(reduce_width_var_mic, 2),
            .y = destination_rect_button.y,
            .w = ButtonPage.size[0] - ButtonPage.size[1] * 2 - reduce_width_var_mic,
            .h = ButtonPage.size[1],
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            AudioManager.sensitivity_microphone.getTexture(),
            null,
            &rect_var_mic,
        );

        //draw word intencity mic.
        const rect_word_mic: c.SDL_Rect = .{
            .x = destination_rect_button.x,
            .y = 0,
            .w = destination_rect_button.w,
            .h = destination_rect_button.h,
        };
        _ = c.SDL_RenderCopy(
            window.renderer,
            WordMenu.texture,
            &WordMenu.getPartText(0),
            &rect_word_mic,
        );
    }

    pub fn click(pos_click: V2, pos_cam: V2) bool {
        if (pos_cam[0] != ButtonPage.size[0])
            return false;

        const pos_button_intencity_substract: V2 = .{
            0,
            ButtonPage.size[1] * 1,
        };
        if (pos_button_intencity_substract[0] < pos_click[0] and
            pos_button_intencity_substract[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_intencity_substract[1] < pos_click[1] and
            pos_button_intencity_substract[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on intencity substract button.

            AudioManager.sensitivity_microphone.set(std.math.clamp(AudioManager.sensitivity_microphone.get() - 1.0, -99.0, 99.0));

            return true;
        }

        const pos_button_intencity_add: V2 = .{
            ButtonPage.size[0] - ButtonPage.size[1],
            ButtonPage.size[1] * 1,
        };
        if (pos_button_intencity_add[0] < pos_click[0] and
            pos_button_intencity_add[0] + ButtonPage.size[1] > pos_click[0] and
            pos_button_intencity_add[1] < pos_click[1] and
            pos_button_intencity_add[1] + ButtonPage.size[1] > pos_click[1])
        {
            //click on intencity add button.

            AudioManager.sensitivity_microphone.set(std.math.clamp(AudioManager.sensitivity_microphone.get() + 1.0, -99.0, 99.0));

            return true;
        }

        return false;
    }
};
