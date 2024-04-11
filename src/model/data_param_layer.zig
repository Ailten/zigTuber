const TalkTypeLayer = @import("../enum/talk_type_layer.zig").TalkTypeLayer;
const PropsTypeLayer = @import("../enum/props_type_layer.zig").PropsTypeLayer;

pub const DataParamLayer = struct { //struct for canva params layer.
    is_active: bool = true,
    z_index: u16 = 0,

    talk_type: TalkTypeLayer = .both,
    props_type: PropsTypeLayer = .no_props,

    anime_ineticity_horizontal: i16 = 0,
    anime_ineticity_vertical: i16 = 0,

    talking_anime_start: ?u32 = null,
    talking_anime_end: ?u32 = null,
};
