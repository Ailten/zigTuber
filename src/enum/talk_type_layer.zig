pub const TalkTypeLayer = enum { //enum for state layer, need to be able or enable, depent on microphone input.
    no_talking,
    talking,
    both,

    last_enum_value_not_to_use,
};
