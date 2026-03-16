# LC_TARGET_TRIPLE

**Command ID:** `0x39`

Embeds the LLVM target triple string directly in the Mach-O binary. The target triple identifies the architecture, vendor, operating system, and optionally the environment -- for example, `arm64-apple-macos15.0.0` or `x86_64-apple-ios17.0.0-simulator`.

This command was introduced in macOS 26 and provides a more precise and machine-readable platform description than `LC_BUILD_VERSION`. While `LC_BUILD_VERSION` encodes the platform and version as numeric fields, the target triple carries the full LLVM triple string as used by the compiler and linker internally.

The triple string immediately follows the load command header and is null-terminated.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_TARGET_TRIPLE`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including the triple string) | 4 | 4 | `UInt32` |
| Triple | Null-terminated LLVM target triple string | 8 | variable | `String` |

**Minimum size:** 8 bytes (header only, before triple string)

## See Also

- [LC_BUILD_VERSION](LC_BUILD_VERSION.md) -- Numeric platform and version information

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_TARGET_TRIPLE.swift`](../../Sources/SwiftMachO/LoadCommands/LC_TARGET_TRIPLE.swift).
