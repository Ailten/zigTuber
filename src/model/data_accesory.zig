const Comand = @import("../enum/comand_type.zig").Comand;

pub const DataAccesory = struct { //struct for event add an accesory.
    nameLayer: []const u8 = undefined, //string of the name layer need to be activated.

    dateWrite: u64 = 0, //date (in milisec) when the file was write.

    cmd: Comand = undefined, //type command.
};
