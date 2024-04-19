const std = @import("std");

pub fn main() !void {
    var buffer_writer = std.io.bufferedWriter(std.io.getStdOut().writer());
    const stdout = buffer_writer.writer();
    try stdout.print("イエーいピースピース。僕はキメ顔でそういった。\n", .{});
    try buffer_writer.flush();

    std.debug.print("Ok {s}\n", .{"zig"});
}

test "Hello test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
