const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub const Widget = struct {
    ptr: *anyopaque,
    renderFn: *const fn (ptr: *anyopaque) anyerror!void,
    handleFn: *const fn (ptr: *anyopaque, Event) anyerror!void,
    pub fn render(self: Widget) !void {
        return self.renderFn(self.ptr);
    }
    pub fn onEvent(self: Widget, event: Event) !void {
        return self.handleFn(self.ptr, event);
    }
};

pub const EventTag = enum { keypress, mouseclick };
pub const Event = union(EventTag) { keypress: rl.KeyboardKey, mouseclick: rl.Vector2 };

// Widget interface
// Has to be able to:
// - point its position, size, opaque internal state
// - have some sort of interfacing functions:
//   - render
//   - onEvent

pub const TestWidget = struct {
    rect: rl.Rectangle,
    pub fn init(position: rl.Vector2, size: rl.Vector2) !*TestWidget {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const a = gpa.allocator();
        const t: *TestWidget = try a.create(TestWidget);

        const tw = TestWidget{ .rect = rl.Rectangle{ .height = size.y, .width = size.x, .x = position.x, .y = position.y } };
        t.* = tw;
        return t;
    }
    pub fn render(ptr: *anyopaque) anyerror!void {
        const self: *TestWidget = @ptrCast(@alignCast(ptr));
        rl.drawRectangle(@intFromFloat(self.rect.x), @intFromFloat(self.rect.y), @intFromFloat(self.rect.width), @intFromFloat(self.rect.height), rl.Color.brown);
    }
    pub fn onEvent(ptr: *anyopaque, event: Event) anyerror!void {
        _ = ptr;
        _ = event;
    }
    pub fn widget(self: *TestWidget) Widget {
        return .{
            .ptr = self,
            .renderFn = render,
            .handleFn = onEvent,
        };
    }
};
