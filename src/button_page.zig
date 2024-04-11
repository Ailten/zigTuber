const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const V2 = @import("v2.zig").V2;
const WindowManager = @import("window_manager.zig").WindowManager;

pub const ButtonPage = struct {
    pub var texture: *c.SDL_Texture = undefined; //texture for button.
    pub var size: V2 = undefined;
    pub const limite_pos_page: V2 = .{ -3, 3 };

    pub fn init(renderer: *c.SDL_Renderer) !void {
        const path_png = "assets/menu/buttonPage.png";

        const file = try std.fs.cwd().openFile(
            path_png,
            .{},
        );
        defer file.close();

        const surface = c.IMG_Load(@ptrCast(path_png)) orelse { //build a surface for texture.
            std.log.err("error to load surface of file : {s}", .{path_png});
            std.log.err("{s}", .{c.SDL_GetError()});
            return error.errorButtonPageSurfaceSDL; //skip if one file can't get texture.
        };
        defer c.SDL_FreeSurface(surface);

        ButtonPage.texture = c.SDL_CreateTextureFromSurface(renderer, surface) orelse { //get texture frome file png.
            std.log.err("error to load texture of file : {s}", .{path_png});
            std.log.err("{s}", .{c.SDL_GetError()});
            return error.errorButtonPageTextureSDL; //skip if one file can't get texture.
        };

        var x_c_int: c_int = undefined; //get size of texture.
        var y_c_int: c_int = undefined;
        _ = c.SDL_QueryTexture( //feed var c_int.
            ButtonPage.texture,
            null,
            null,
            &x_c_int,
            &y_c_int,
        );

        ButtonPage.size = .{ //size V2 from texture.
            @intCast(x_c_int),
            @intCast(y_c_int),
        };
    }

    pub fn deinit() void {
        c.SDL_DestroyTexture(ButtonPage.texture);
    }

    pub fn draw(window: *WindowManager) !void {
        //position.
        var destination_rect: c.SDL_Rect = c.SDL_Rect{
            .x = 0, //pos to draw.
            .y = (ButtonPage.size[1] * 9), //pos for page fix.
            .w = ButtonPage.size[0], //size texture.
            .h = ButtonPage.size[1],
        };
        if (isPageWithScroll(&window.pos_cam)) //pos for page scrollable.
            destination_rect.y = (window.pos_cam[1] * -1 + ButtonPage.size[1]);

        var rect_texture_cut: ?c.SDL_Rect = null;
        if (window.pos_cam[0] == ButtonPage.limite_pos_page[0] * ButtonPage.size[0]) {
            rect_texture_cut = .{
                .x = ButtonPage.size[0] - ButtonPage.size[1],
                .y = 0,
                .w = ButtonPage.size[1],
                .h = ButtonPage.size[1],
            };
            destination_rect.x += ButtonPage.size[0] - ButtonPage.size[1];
            destination_rect.w = ButtonPage.size[1];
        } else if (window.pos_cam[0] == ButtonPage.limite_pos_page[1] * ButtonPage.size[0]) {
            rect_texture_cut = .{
                .x = 0,
                .y = 0,
                .w = ButtonPage.size[1],
                .h = ButtonPage.size[1],
            };
            destination_rect.w = ButtonPage.size[1];
        }

        //draw texture button.
        const error_code = c.SDL_RenderCopy( //draw a texture.
            window.renderer,
            ButtonPage.texture,
            if (rect_texture_cut) |*rect_texture_cut_nonull| rect_texture_cut_nonull else null, //part texture draw (all).
            &destination_rect, //pos to draw.
        );
        if (error_code != 0) { //error c to zig.
            return error.renderCopy;
        }
    }

    pub fn click(pos_click: V2, pos_cam: *V2) bool {
        const pos_click_world: V2 = .{
            pos_click[0] + pos_cam[0],
            pos_click[1] + pos_cam[1],
        };

        var pos_layer_button: V2 = .{
            pos_cam[0],
            ButtonPage.size[1],
        };
        if (!isPageWithScroll(pos_cam))
            pos_layer_button[1] = pos_cam[1] + ButtonPage.size[1] * 9; //pos for page fix.

        if (pos_layer_button[0] < pos_click_world[0] and
            pos_layer_button[0] + ButtonPage.size[1] > pos_click_world[0] and
            pos_layer_button[1] < pos_click_world[1] and
            pos_layer_button[1] + ButtonPage.size[1] > pos_click_world[1])
        {
            //button left.

            if (ButtonPage.limite_pos_page[0] * ButtonPage.size[0] == pos_cam[0])
                return true; //already on first page.

            pos_cam[0] -= ButtonPage.size[0]; //scroll left.

            pos_cam[1] = ButtonPage.size[1] * 8 * -1; //reset pos y.

            return true;
        }

        pos_layer_button[0] += ButtonPage.size[0] - ButtonPage.size[1];

        if (pos_layer_button[0] < pos_click_world[0] and
            pos_layer_button[0] + ButtonPage.size[1] > pos_click_world[0] and
            pos_layer_button[1] < pos_click_world[1] and
            pos_layer_button[1] + ButtonPage.size[1] > pos_click_world[1])
        {
            //button right.

            if (ButtonPage.limite_pos_page[1] * ButtonPage.size[0] == pos_cam[0])
                return true; //already on last page.

            pos_cam[0] += ButtonPage.size[0]; //scroll right.

            pos_cam[1] = ButtonPage.size[1] * 8 * -1; //reset pos y.

            return true;
        }

        return false;
    }

    fn isPageWithScroll(pos_cam: *V2) bool {
        return (pos_cam[0] <= 0); //all page on left is scrollable (layers params).
    }
};
