const std = @import("std");

const Version = u64;
const stripe_size = std.atomic.cache_line;

const TransactionalMem = struct {
    clock: std.atomic.Value(Version) align(std.atomic.cache_line) = .init(0),
    locks: []std.atomic.Value(Version),

    const Self = @This();

    const Options = struct {
        num_locks: usize = 2 << 20,
    };

    pub fn init(gpa: std.mem.Allocator, opts: Options) !Self {
        return .{
            .clock = .init(0),
            .locks = try gpa.alloc(std.atomic.Value(Version), opts.num_locks),
        };
    }
    pub fn deinit(self: *Self, gpa: std.mem.Allocator) void {
        gpa.free(self.locks);
    }

    pub fn stripeIndex(self: *const Self, ptr: *anyopaque) usize {
        const addr: usize = @intFromPtr(ptr);
        // TODO: fix recalc
        const stripe_size_log2 = std.math.log2_int(usize, stripe_size);
        const line = addr >> stripe_size_log2;

        // fibonacci hashing
        const hash = line *% 0x9E3779B97F4A7C15;
        // TODO: fix recalc - change options var?
        return hash >> (64 - std.math.log2int(usize, self.locks.len)); 

    }
};

const Transaction = struct {
    mem: *TransactionalMem,
    clock_read_version: Version,
    depth: u32,

    load_log: std.MultiArrayList(struct {
        addr: *anyopaque,
        read_version: Version,
    }),
    // writes: WriteSet,

    const Self = @This();

    pub fn loadBytes(self: *Self, dst: []u8, src: [*]const u8) !void {
        // TODO
    }

    pub fn storeBytes(self: *Self, dst: [*]u8, src: []const u8) !void {
        // TODO
    }
};
