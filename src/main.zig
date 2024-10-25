//imports
const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const wgt = @import("widget.zig");
const bprint = std.fmt.bufPrint;

var random_arraylist: std.ArrayList(u8) = std.ArrayList(u8)
    .init(std.heap.c_allocator);

//shortcuts
const assert = std.debug.assert;
const print = std.debug.print;
const get_time = std.time.milliTimestamp;

// structs
const Entity = struct {
    position: rl.Vector2,
    movement: rl.Vector2,
    fn init() Entity {
        return Entity{ .position = rl.Vector2{ .x = @divFloor(screenWidth, 2), .y = @divFloor(screenHeight, 2) }, .movement = rl.Vector2{ .x = 0, .y = 0 } };
    }

    fn move(self: *Entity) void {
        self.position.x = @mod((self.position.x + self.movement.x), screenWidth);
        self.position.y = @mod((self.position.y - self.movement.y), screenHeight);
    }

    fn steer(self: *Entity, k: rl.KeyboardKey) void {
        switch (k) {
            rl.KeyboardKey.key_up => self.movement.y += 1,
            rl.KeyboardKey.key_down => self.movement.y -= 1,
            rl.KeyboardKey.key_left => self.movement.x -= 1,
            rl.KeyboardKey.key_right => self.movement.x += 1,
            rl.KeyboardKey.key_space => {
                self.movement.x = 0;
                self.movement.y = 0;
            },
            else => {},
        }
    }
};

// Initialization
const screenWidth = 800;
const screenHeight = 450;
var entity: Entity = undefined;

var time: f32 = 0;

pub fn main() !void {
    const wg: *wgt.TestWidget = try wgt.TestWidget.init(rl.Vector2{ .x = 10, .y = 20 }, rl.Vector2{ .x = 100, .y = 50 });
    const widget: wgt.Widget = wg.widget();

    rl.initWindow(screenWidth, screenHeight, "window");
    defer rl.closeWindow(); // Close window and OpenGL context
    entity = Entity.init();
    const rectangle = rl.Rectangle{ .height = 100, .width = 100, .x = 50, .y = 50 };
    var button_clicked: i32 = 0;
    var timer_array: [6:0]u8 = .{0} ** 6;
    const timer_ptr: [:0]u8 = &timer_array;
    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        time += rl.getFrameTime();
        _ = try bprint(timer_ptr, "{d:^4.2}", .{time});
        button_clicked = rg.guiButton(rectangle, "Well");
        if (button_clicked != 0) {
            reset_timer();
        }
        const kk: rl.KeyboardKey = rl.getKeyPressed();
        switch (kk) {
            rl.KeyboardKey.key_r => reset_timer(),
            else => entity.steer(kk),
        }

        entity.move();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);
        rl.drawText(timer_ptr, 190, 200, 20, rl.Color.light_gray);
        rl.drawCircle(@intFromFloat(entity.position.x), @intFromFloat(entity.position.y), 20, rl.Color.maroon);
        try widget.render();
        defer rl.endDrawing();
    }
}
fn reset_timer() void {
    time = 0;
}
