# LC_SOURCE_VERSION

**Command ID:** `0x2A`

Records the version of the source code used to build the binary. This is a purely informational field set by the build system -- the kernel and `dyld` do not use it for compatibility checks. Tools like `otool -l` and `vtool` display it, making it useful for identifying which source revision produced a given binary.

The version is packed into a single 64-bit integer as five components: `A.B.C.D.E`. The encoding is:

```
A (24 bits) . B (10 bits) . C (10 bits) . D (10 bits) . E (10 bits)
```

For example, version `650.9.0.0.0` is encoded as `(650 << 40) | (9 << 30)`.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_SOURCE_VERSION`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Version | Packed source version (`A.B.C.D.E`) | 8 | 8 | `UInt64` |

**Fixed size:** 16 bytes

## See Also

- [LC_BUILD_VERSION](LC_BUILD_VERSION.md) -- Platform, OS, SDK, and build tool versions (separate from source version)

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SOURCE_VERSION.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SOURCE_VERSION.swift).
