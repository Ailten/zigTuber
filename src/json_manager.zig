const std = @import("std"); //lib base.
const Layer = @import("layer.zig").Layer;
const DataParam = @import("model/data_param.zig").DataParam;
const DataParamPrintable = @import("model/data_param.zig").DataParamPrintable;
const DataParamLayer = @import("model/data_param_layer.zig").DataParamLayer;
const DataAccesory = @import("model/data_accesory.zig").DataAccesory;
const AllocatorManager = @import("allocator_manager.zig").AllocatorManager;
const c = @import("c.zig"); //import all C lib declared.

pub const JsonManager = struct { //struct for doing read and write in file.

    const path_params = "assets/params/params.json";
    const path_params_layers = "assets/paramsLayers";

    pub var data_params: DataParamPrintable = undefined;

    var buffer_path_params_layers: [256:0]u8 = undefined;

    pub fn loadParams(renderer_menu: *c.SDL_Renderer) !void {
        const file = std.fs.cwd().openFile(path_params, .{}) catch |err| { //open file.
            switch (err) {
                error.FileNotFound => {
                    JsonManager.data_params = .{}; //init with default value.
                    return;
                },
                else => return err,
            }
        };
        defer file.close();

        var file_str = std.ArrayList(u8).init(AllocatorManager.arena_allocator);
        errdefer file_str.deinit(); //deinit if error or when exe close.

        try file.reader().readAllArrayList( //read file.
            &file_str,
            std.math.maxInt(usize),
        );

        const json_read = try std.json.parseFromSlice( //get json parsed.
            DataParam,
            AllocatorManager.arena_allocator,
            file_str.items,
            .{},
        );
        errdefer json_read.deinit();

        const value_read = json_read.value; //get value fo json parsed.

        JsonManager.data_params = DataParamPrintable.import_data(value_read, renderer_menu); //get value fo json parsed.

        // --- init time edit file accesory.

        const stats_file_accesory = try std.fs.cwd().statFile(path_file_accesory);
        last_time_file_edit = stats_file_accesory.mtime;
    }

    pub fn saveParams() !void {
        const value_to_write = JsonManager.data_params.export_data(); //get params to save.

        var flag_file_exist = true; //flag for know if file exist.
        std.fs.cwd().access(path_params, .{}) catch |err| {
            switch (err) {
                error.FileNotFound => flag_file_exist = false,
                else => {},
            }
        };

        if (flag_file_exist) { //delete if the layer have a previous param saved.
            try std.fs.cwd().deleteFile(path_params);
        }
        const file = try std.fs.cwd().createFile(path_params, .{});
        defer file.close();

        //const file = try if (flag_file_exist)
        //    std.fs.cwd().openFile(path_params, .{ .mode = .write_only })
        //else
        //    std.fs.cwd().createFile(path_params, .{});
        //defer file.close();

        try std.json.stringify(value_to_write, .{}, file.writer()); //write in file.
    }

    pub fn concatPathParamsLayer(name: []const u8) ![]const u8 {
        return try std.fmt.bufPrint( //path of layer params file.
            &buffer_path_params_layers,
            "{s}/{s}.json",
            .{ path_params_layers, name },
        );
    }

    pub fn loadParamsLayer(layer: *Layer, renderer_menu: *c.SDL_Renderer) !void {
        const path_current_file = try concatPathParamsLayer(layer.name.items);

        const file = std.fs.cwd().openFile(path_current_file, .{}) catch |err| { //open file.
            switch (err) {
                error.FileNotFound => return, //skip if no file found.
                else => return err,
            }
        };
        defer file.close();

        var file_str = std.ArrayList(u8).init(AllocatorManager.arena_allocator);
        errdefer file_str.deinit(); //deinit if error or when exe close.

        try file.reader().readAllArrayList( //read file.
            &file_str,
            std.math.maxInt(usize),
        );

        const json_read = try std.json.parseFromSlice( //get json parsed.
            DataParamLayer,
            AllocatorManager.arena_allocator,
            file_str.items,
            .{},
        );
        errdefer json_read.deinit();

        const value_read = json_read.value; //get value fo json parsed.

        layer.loadParams(value_read, renderer_menu); //set data to layer.

    }

    pub fn saveParamsLayer(layer: Layer) !void {
        const value_to_write = layer.exportParams(); //get params to save.

        const path_current_file = try concatPathParamsLayer(layer.name.items);

        var flag_file_exist = true; //flag for know if file exist.
        std.fs.cwd().access(path_current_file, .{}) catch |err| {
            switch (err) {
                error.FileNotFound => flag_file_exist = false,
                else => {},
            }
        };

        if (flag_file_exist) { //delete if the layer have a previous param saved.
            try std.fs.cwd().deleteFile(path_current_file);
        }
        const file = try std.fs.cwd().createFile(path_current_file, .{});
        defer file.close();

        //const file = try if (flag_file_exist)
        //    std.fs.cwd().openFile(path_current_file, .{ .mode = .write_only })
        //else
        //    std.fs.cwd().createFile(path_current_file, .{});
        //defer file.close();

        try std.json.stringify(value_to_write, .{}, file.writer()); //write in file.

    }

    pub const path_file_accesory = "assets/fileAccesory/fileAccesory.json";
    pub var last_time_file_edit: i128 = 0;

    pub fn readJsonAccesory(layers: *std.ArrayList(Layer)) !void {
        if (!JsonManager.data_params.read_file_accesory)
            return;

        const stats_file_accesory = try std.fs.cwd().statFile(path_file_accesory);
        if (stats_file_accesory.mtime == last_time_file_edit)
            return;

        last_time_file_edit = stats_file_accesory.mtime;

        const file = try std.fs.cwd().openFile(path_file_accesory, .{}); //open file.
        defer file.close();

        var file_str = std.ArrayList(u8).init(AllocatorManager.arena_update_allocator);
        errdefer file_str.deinit(); //deinit if error or when exe close.

        try file.reader().readAllArrayList( //read file.
            &file_str,
            std.math.maxInt(usize),
        );

        if (file_str.items.len == 0) { //read during write.
            return;
        }

        const json_read = try std.json.parseFromSlice( //get json parsed.
            DataAccesory,
            AllocatorManager.arena_update_allocator,
            file_str.items,
            .{},
        );
        errdefer json_read.deinit();

        const current_accesory = json_read.value; //get value fo json parsed.

        switch (current_accesory.cmd) {
            .activ_layer => {
                //do the proces fo switch layer accesory.
                Layer.switchAccesory(
                    layers, //array list of all layers.
                    current_accesory.nameLayer, //name of layer need to active.
                );
            },
        }
    }

    pub fn saveData(layers: *std.ArrayList(Layer)) !void {
        //save befor close exe.
        try JsonManager.saveParams();
        for (layers.items) |layer| {
            try JsonManager.saveParamsLayer(layer);
        }
    }
};
