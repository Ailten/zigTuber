const std = @import("std"); //lib base.
const c = @import("c.zig"); //import all C lib declared.
const Layer = @import("layer.zig").Layer;
const V2 = @import("v2.zig").V2;
const JsonManager = @import("json_manager.zig").JsonManager;
const Update = @import("update.zig").Update;
const AudioManager = @import("miniaudio_wrapper.zig").AudioManager;
const WindowManager = @import("window_manager.zig").WindowManager;
const ButtonLayer = @import("button_layer.zig").ButtonLayer;
const ButtonPage = @import("button_page.zig").ButtonPage;
const AudioGraph = @import("audio_graph.zig").AudioGraph;
const ButtonEnum = @import("button_enum.zig").ButtonEnum;
const AllocatorManager = @import("allocator_manager.zig").AllocatorManager;
const WordMenu = @import("word_menu.zig").WordMenu;
const WindowPage = @import("window_page.zig").WindowPage;
const AnimePage = @import("anime_page.zig").AnimePage;
const AnimeLayerPage = @import("anime_layer_page.zig").AnimeLayerPage;
const AnimeTalkPage = @import("anime_talk_page.zig").AnimeTalkPage;
const os = std.os; //for time edit os.

pub fn main() !void {
    AllocatorManager.init(); //manager memlory allocators.
    defer AllocatorManager.deinit();

    var window_png_tuber = try WindowManager.init("ZigTuber"); //window.
    defer window_png_tuber.deinit();
    window_png_tuber.background_color = .{ 0, 255, 0, 255 };

    var window_menu = try WindowManager.init("Menu"); //menu.
    defer window_menu.deinit();

    //init the font lib.
    if (c.TTF_Init() != 0) {
        std.log.err("error to init TTF", .{});
        return error.errorTTFinit;
    }

    var layers = std.ArrayList(Layer).init(AllocatorManager.arena_allocator); //make a list of layer.
    defer {
        for (layers.items) |*layer| {
            layer.deinit();
        }
        layers.deinit();
    }

    try Layer.loadLayers( //load all layer from file.
        window_png_tuber.renderer,
        &layers,
        "assets/layers",
    );
    if (layers.items.len == 0) {
        std.log.err("error no file found in folder layer", .{});
        return;
    }

    //init all struct for menu.
    try ButtonLayer.init(window_menu.renderer); //init button layer.
    defer ButtonLayer.deinit();
    try ButtonPage.init(window_menu.renderer); //init button page.
    defer ButtonPage.deinit();
    try ButtonEnum.init(window_menu.renderer); //init button enum.
    defer ButtonEnum.deinit();
    try WordMenu.init(window_menu.renderer); //init texture word.
    defer WordMenu.deinit();

    window_menu.resize(.{
        ButtonLayer.size[0],
        ButtonLayer.size[1] * 10,
    });
    window_menu.pos_cam[1] = ButtonLayer.size[1] * 8 * -1;

    //load json.
    try JsonManager.loadParams(window_menu.renderer);
    for (layers.items) |*layer| {
        try JsonManager.loadParamsLayer(
            layer,
            window_menu.renderer,
        );
    }

    Update.eval_milisec_by_frame(JsonManager.data_params.fps.get()); //manage the fps update.

    const size_first_layer = layers.items[0].getSize(); //resize window in size of first layer.
    window_png_tuber.resize(.{
        size_first_layer[0],
        size_first_layer[1],
    });

    std.mem.sort( //order by z index.
        Layer,
        layers.items,
        void{},
        Layer.lessThan,
    );
    for (layers.items, 0..) |*layer, index| { //remap z index from 0 to n (by margin of 1 only).
        layer.z_index = @intCast(index);
    }

    //std.debug.print("\n", .{});
    //for (layers.items) |*layer| {
    //    std.debug.print("layer : {s} n{}\n", .{ layer.name.items, layer.z_index });
    //}

    //audio manager.
    try AudioManager.init(); //arena_allocator
    defer AudioManager.deinit();
    AudioManager.min_decibel_for_talking = JsonManager.data_params.min_decibel_for_talking; //apply param for audio.
    AudioManager.sensitivity_microphone.init(JsonManager.data_params.sensitivity_microphone, window_menu.renderer);

    var is_edit_menu_maked = false; //bool for flag params is save.

    var event: c.SDL_Event = undefined;
    loop_update: while (true) { //loop for update.

        Update.saveTimeBeforeProcess(); //time before process. --->

        //free arena allocator.
        const result_arena_reset = AllocatorManager.arena_update.reset(.retain_capacity);
        if (!result_arena_reset) {
            std.log.err("error in arena.reset", .{});
            break :loop_update;
        }

        //TODO: event lost when two window open.

        while (c.SDL_PollEvent(&event) != 0) { //loop for events in frame.
            switch (event.type) {
                c.SDL_QUIT => { //event to close the app (work if only one window).
                    break :loop_update;
                },
                c.SDL_WINDOWEVENT => {
                    if (event.window.event == c.SDL_WINDOWEVENT_CLOSE) //event to close the app (work with many window).
                        break :loop_update;
                },
                c.SDL_MOUSEBUTTONDOWN => {
                    if (c.SDL_GetWindowFromID(event.window.windowID) != window_menu.window)
                        break;

                    const click_pos: V2 = .{ //get pos of mouse click.
                        @intCast(event.button.x),
                        @intCast(event.button.y),
                    };

                    if (ButtonLayer.click(
                        click_pos,
                        &layers,
                        window_menu.pos_cam,
                    )) {
                        is_edit_menu_maked = true;
                        break;
                    }

                    if (ButtonPage.click(
                        click_pos,
                        &window_menu.pos_cam,
                    )) break;

                    if (ButtonEnum.click(
                        click_pos,
                        &layers,
                        window_menu.pos_cam,
                    )) {
                        is_edit_menu_maked = true;
                        break;
                    }

                    if (AudioGraph.click(
                        click_pos,
                        window_menu.pos_cam,
                    )) {
                        is_edit_menu_maked = true;
                        break;
                    }

                    if (WindowPage.click(
                        click_pos,
                        window_menu.pos_cam,
                        &window_png_tuber,
                        layers.items[0].getSizeBase(),
                        &is_edit_menu_maked,
                        &layers,
                    )) break;

                    if (AnimePage.click(
                        click_pos,
                        window_menu.pos_cam,
                    )) {
                        is_edit_menu_maked = true;
                        break;
                    }

                    if (AnimeLayerPage.click(
                        click_pos,
                        window_menu.pos_cam,
                        &layers,
                    )) {
                        is_edit_menu_maked = true;
                        break;
                    }

                    if (AnimeTalkPage.click(
                        click_pos,
                        window_menu.pos_cam,
                        &layers,
                    )) {
                        is_edit_menu_maked = true;
                        break;
                    }

                    //std.debug.print(" --- Click empty space \n", .{});
                },
                c.SDL_MOUSEWHEEL => {
                    if (c.SDL_GetWindowFromID(event.window.windowID) != window_menu.window)
                        break;

                    //do the scrolling.
                    window_menu.pos_cam[1] += @divFloor(ButtonLayer.size[1], 2) * @as(i16, @intCast(event.wheel.y)) * -1;
                },
                else => {}, //event type not handled.
            }
        }

        //read json for accesory update.
        try JsonManager.readJsonAccesory(
            &layers, //array of layers.
        );

        window_png_tuber.clean(); //clean renderer layers.
        window_menu.clean(); //clean renderer menu.

        for (layers.items) |*layer| { //draw all layers.
            layer.draw(window_png_tuber.renderer) catch |err| {
                std.log.err("error in layer.draw : {}", .{err});
                break :loop_update;
            };

            ButtonLayer.draw(layer, &window_menu) catch |err| {
                std.log.err("error in ButtonLayer.draw( : {}", .{err});
                break :loop_update;
            };
            ButtonEnum.draw(layer, &window_menu) catch |err| {
                std.log.err("error in ButtonEnum.draw : {}", .{err});
                break :loop_update;
            };
            AnimeLayerPage.draw(layer, &window_menu) catch |err| {
                std.log.err("error in AnimeLayerPage.draw( : {}", .{err});
                break :loop_update;
            };
            AnimeTalkPage.draw(layer, &window_menu) catch |err| {
                std.log.err("error in AnimeTalkPage.draw( : {}", .{err});
                break :loop_update;
            };
        }
        ButtonPage.draw(&window_menu) catch |err| {
            std.log.err("error in ButtonPage.draw : {}", .{err});
            break :loop_update;
        };
        AudioGraph.draw(&window_menu) catch |err| {
            std.log.err("error in AudioGraph.draw : {}", .{err});
            break :loop_update;
        };
        WindowPage.draw(
            &window_menu,
            &is_edit_menu_maked,
        ) catch |err| {
            std.log.err("error in WindowPage.draw : {}", .{err});
            break :loop_update;
        };
        AnimePage.draw(&window_menu) catch |err| {
            std.log.err("error in AnimePage.draw : {}", .{err});
            break :loop_update;
        };
        AnimeTalkPage.drawFix(&window_menu) catch |err| {
            std.log.err("error in AnimeTalkPage.drawFix : {}", .{err});
            break :loop_update;
        };

        AudioManager.clearBufferSafely(); //reset the buffer audio.

        window_png_tuber.applyRender(); //draw the renderer layers.
        window_menu.applyRender(); //draw renderer menu.

        Update.saveTimeAfterProcess(); //time after process. --->
        Update.waitEndProcess(); //wait end current update.
    }
}
