return {

    -- Pins you want to controll. Adjust to your needs
    -- pins = { 1, 2, 3, 4, 5 },

    -- pins = { 14, 15, 18, 23, 24, 25, 8, 7,   2, 3, 4, 17, 27, 22, 10, 9},

    pins = {
        {pin = 3, name="Gehäusebeleuchtung", invert=true},

        {pin = 14},
        {pin = 15},
        {pin = 18},
        {pin = 23},
        {pin = 24},
        {pin = 25},
        {pin = 8},
        {pin = 7},
        {pin = 2},
        {pin = 4},
        {pin = 17},
        {pin = 27},
        {pin = 22},
        {pin = 10},
        {pin = 9},
    },


    -- Port the webserver binds to.
    webport = 8080,

    -- Path of the mustache template
    template_path = "template.mustache"

}
