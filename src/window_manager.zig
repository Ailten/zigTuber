const std = @import("std");
const c = @import("c.zig"); //import all C lib declared.
const V2 = @import("v2.zig").V2;

pub const WindowManager = struct {
    window: *c.struct_SDL_Window = undefined,
    renderer: *c.SDL_Renderer = undefined,

    pos_cam: V2 = .{ 0, 0 },

    background_color: @Vector(4, u8) = .{ 0, 0, 0, 255 },

    pub fn init(title: [*]const u8) !@This() {
        var self: @This() = .{};

        if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) { //init sdl video.
            std.log.err("error find in sdl video", .{});
            return error.errorSDLvideo;
        }
        errdefer c.SDL_Quit(); //close sdl.

        const flag_img = c.IMG_INIT_PNG;
        if (c.IMG_Init(flag_img) != flag_img) { //init sdl surface.
            std.log.err("error find in sdl surface", .{});
            return error.errorSDLsurface;
        }
        errdefer c.IMG_Quit(); //close sdl img.

        self.window = c.SDL_CreateWindow( //create a window.
            title,
            0,
            0,
            200,
            150,
            0,
        ) orelse {
            std.log.err("error find in window init", .{});
            return error.errorWindowInit;
        };
        errdefer c.SDL_Quit(); //close sdl.

        self.renderer = c.SDL_CreateRenderer( //create a renderer.
            self.window, -1, //magik number.
            c.SDL_RENDERER_ACCELERATED //magik flag.
        ) orelse {
            std.log.err("error find in render init", .{});
            return error.errorRenderInit;
        };

        return self;
    }

    pub fn deinit(self: @This()) void {
        //no deinit for renderer.
        c.SDL_DestroyWindow(self.window); //close window.
        c.IMG_Quit(); //close sdl img.
        c.SDL_Quit(); //close sdl.
    }

    pub fn resize(self: @This(), size: V2) void {
        c.SDL_SetWindowSize(
            self.window,
            size[0],
            size[1],
        );
    }

    pub fn clean(self: @This()) void {
        _ = c.SDL_SetRenderDrawColor(
            self.renderer,
            self.background_color[0],
            self.background_color[1],
            self.background_color[2],
            self.background_color[3],
        );
        _ = c.SDL_RenderClear(self.renderer);
    }

    pub fn applyRender(self: @This()) void {
        c.SDL_RenderPresent(self.renderer);
    }
};
