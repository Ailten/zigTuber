//import script from C.
pub usingnamespace @cImport({
    @cInclude("SDL2/SDL.h"); //import lib sdl in C to zig.
    @cInclude("SDL2/SDL_image.h"); //import lib sdl in C to zig (for surface).
    @cInclude("SDL2/SDL_ttf.h"); //import lib sdl in C to zig (for font/text).
    @cInclude("miniaudio.h"); //miniaudio.
});
