const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const AllocatorManager = @import("allocator_manager.zig").AllocatorManager;

pub fn ValuePrintable(comptime type_send: type) type {
    return struct {
        value: type_send = undefined,
        texture: *c.SDL_Texture = undefined,
        renderer: *c.SDL_Renderer = undefined,

        pub fn init(self: *@This(), value_send: type_send, renderer_send: *c.SDL_Renderer) void {
            self.value = value_send;
            self.renderer = renderer_send;

            self.makeTexture() catch {
                return;
            };
        }

        pub fn get(self: @This()) type_send {
            return self.value;
        }

        pub fn set(self: *@This(), value_set: type_send) void {
            if (self.value == value_set)
                return;

            self.value = value_set;
            self.makeTexture() catch {
                return;
            };
        }

        fn makeTexture(self: *@This()) !void {
            if (@typeInfo(@TypeOf(self.value)) == .Optional) { //check if value is nullable.

                if (self.value == null) { //check if value is null.
                    try self.makeTextureNull();
                    return;
                }

                try self.makeTextureNullable();
                return;
            }

            //cast value to string.
            const str_canvas = "{d:.1}{c}";
            const size_buffer_str = @as(usize, @intCast(std.fmt.count(
                str_canvas,
                .{ self.value, 0 },
            )));
            const buffer_str = try AllocatorManager.allocator.alloc(u8, size_buffer_str);
            defer AllocatorManager.allocator.free(buffer_str);
            const value_str: []u8 = try std.fmt.bufPrint(
                buffer_str,
                str_canvas,
                .{
                    self.value,
                    0,
                },
            );

            //make texture from value_string.
            const font: *c.TTF_Font = c.TTF_OpenFont("assets/menu/font/emmasophia.ttf", 25) orelse {
                std.log.err("error to open font TTF : {s}", .{c.TTF_GetError()});
                return error.errorTTFopenFont;
            };
            const color_text: c.SDL_Color = .{
                .r = 255,
                .g = 255,
                .b = 255,
                .a = 255,
            };
            const surface_text = c.TTF_RenderText_Solid( //Blended.
                font,
                @ptrCast(value_str),
                color_text,
            );
            defer c.SDL_FreeSurface(surface_text);
            self.texture = c.SDL_CreateTextureFromSurface(self.renderer, surface_text) orelse {
                return error.errorCreateTextureSDL;
            };
        }

        fn makeTextureNullable(self: *@This()) !void {

            //cast value to string.
            const str_canvas = "{?d:.1}{c}";
            const size_buffer_str = @as(usize, @intCast(std.fmt.count(
                str_canvas,
                .{ self.value, 0 },
            )));
            const buffer_str = try AllocatorManager.allocator.alloc(u8, size_buffer_str);
            defer AllocatorManager.allocator.free(buffer_str);
            const value_str: []u8 = try std.fmt.bufPrint(
                buffer_str,
                str_canvas,
                .{
                    self.value,
                    0,
                },
            );

            //make texture from value_string.
            const font: *c.TTF_Font = c.TTF_OpenFont("assets/menu/font/emmasophia.ttf", 25) orelse {
                std.log.err("error to open font TTF : {s}", .{c.TTF_GetError()});
                return error.errorTTFopenFont;
            };
            const color_text: c.SDL_Color = .{
                .r = 255,
                .g = 255,
                .b = 255,
                .a = 255,
            };
            const surface_text = c.TTF_RenderText_Solid( //Blended.
                font,
                @ptrCast(value_str),
                color_text,
            );
            defer c.SDL_FreeSurface(surface_text);
            self.texture = c.SDL_CreateTextureFromSurface(self.renderer, surface_text) orelse {
                return error.errorCreateTextureSDL;
            };
        }

        fn makeTextureNull(self: *@This()) !void {

            //cast value to string.
            const str_canvas = "{s}{c}";
            const size_buffer_str = @as(usize, @intCast(std.fmt.count(
                str_canvas,
                .{ "null", 0 },
            )));
            const buffer_str = try AllocatorManager.allocator.alloc(u8, size_buffer_str);
            defer AllocatorManager.allocator.free(buffer_str);
            const value_str: []u8 = try std.fmt.bufPrint(
                buffer_str,
                str_canvas,
                .{
                    "null",
                    0,
                },
            );

            //make texture from value_string.
            const font: *c.TTF_Font = c.TTF_OpenFont("assets/menu/font/emmasophia.ttf", 25) orelse {
                std.log.err("error to open font TTF : {s}", .{c.TTF_GetError()});
                return error.errorTTFopenFont;
            };
            const color_text: c.SDL_Color = .{
                .r = 255,
                .g = 255,
                .b = 255,
                .a = 255,
            };
            const surface_text = c.TTF_RenderText_Solid( //Blended.
                font,
                @ptrCast(value_str),
                color_text,
            );
            defer c.SDL_FreeSurface(surface_text);
            self.texture = c.SDL_CreateTextureFromSurface(self.renderer, surface_text) orelse {
                return error.errorCreateTextureSDL;
            };
        }

        pub fn getTexture(self: @This()) *c.SDL_Texture {
            return self.texture;
        }
    };
}
