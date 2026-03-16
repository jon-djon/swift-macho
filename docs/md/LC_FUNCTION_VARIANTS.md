# LC_FUNCTION_VARIANTS

**Command ID:** `0x37`

Describes function variant information for the binary. Function variants allow multiple implementations of the same function to exist, with the appropriate version selected at runtime based on CPU capabilities or other criteria (e.g. selecting an AVX-optimized version on hardware that supports it).

This command was introduced in macOS 26 / iOS 19 and is not yet widely documented. The implementation currently parses only the load command header.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_FUNCTION_VARIANTS`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command | 4 | 4 | `UInt32` |

**Minimum size:** 8 bytes

## See Also

- [LC_FUNCTION_VARIANT_FIXUPS](LC_FUNCTION_VARIANT_FIXUPS.md) -- Fixup data for resolving function variant pointers at load time
- [LC_FUNCTION_STARTS](LC_FUNCTION_STARTS.md) -- Function boundary information

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_FUNCTION_VARIANTS.swift`](../../Sources/SwiftMachO/LoadCommands/LC_FUNCTION_VARIANTS.swift).
