# LC_MAIN

**Command ID:** `0x80000028` (`LC_REQ_DYLD | 0x28`)

Specifies the entry point and initial stack size for the main thread of a Mach-O executable. This load command replaced `LC_UNIXTHREAD` as the standard way to define an executable's entry point starting with OS X 10.8.

The `entryOff` field is an offset relative to the start of the `__TEXT` segment, not an absolute virtual address. The dynamic linker (`dyld`) adds this offset to the `__TEXT` segment's load address to compute the actual entry point at runtime.

If `stackSize` is 0, the operating system uses its default stack size.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_MAIN`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (24 bytes) | 4 | 4 | `UInt32` |
| Entry Offset | Offset of the entry point relative to the `__TEXT` segment | 8 | 8 | `UInt64` |
| Stack Size | Initial stack size in bytes (0 = default) | 16 | 8 | `UInt64` |

**Total size:** 24 bytes

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_MAIN.swift`](../../Sources/SwiftMachO/LoadCommands/LC_MAIN.swift).
