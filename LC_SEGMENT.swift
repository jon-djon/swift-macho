import Foundation

/// Mach-O 32-bit segment load command structure
/// The segment load command indicates that a part of this file is to be
/// mapped into the task's address space.
struct LC_SEGMENT {
    /// Load command type (LC_SEGMENT)
    var cmd: UInt32

    /// Total size of this command in bytes
    var cmdsize: UInt32

    /// Segment name (16 bytes, null-padded)
    var segname: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                  UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    /// Memory address of this segment
    var vmaddr: UInt32

    /// Memory size of this segment
    var vmsize: UInt32

    /// File offset of this segment
    var fileoff: UInt32

    /// Amount to map from the file
    var filesize: UInt32

    /// Maximum VM protection
    var maxprot: Int32

    /// Initial VM protection
    var initprot: Int32

    /// Number of sections in this segment
    var nsects: UInt32

    /// Flags
    var flags: UInt32
}
