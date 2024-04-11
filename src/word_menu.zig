const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const WindowManager = @import("window_manager.zig").WindowManager;
const ButtonPage = @import("button_page.zig").ButtonPage;

pub const WordMenu = struct {
    pub var texture: *c.SDL_Texture = undefined; //texture for all word.

    pub fn init(renderer: *c.SDL_Renderer) !void {
        const path_png = "assets/menu/wordMenu.png";

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

        WordMenu.texture = c.SDL_CreateTextureFromSurface(renderer, surface) orelse { //get texture frome file png.
            std.log.err("error to load texture of file : {s}", .{path_png});
            std.log.err("{s}", .{c.SDL_GetError()});
            return error.errorButtonLayerTextureSDL; //skip if one file can't get texture.
        };
    }

    pub fn deinit() void {
        c.SDL_DestroyTexture(WordMenu.texture);
    }

    pub fn getPartText(index_word: u8) c.SDL_Rect {
        return .{
            .x = 0,
            .y = ButtonPage.size[1] * index_word,
            .w = ButtonPage.size[0],
            .h = ButtonPage.size[1],
        };
    }
};
