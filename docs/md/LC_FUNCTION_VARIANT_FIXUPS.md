# LC_FUNCTION_VARIANT_FIXUPS

**Command ID:** `0x38`

Points to function variant fixup data stored in the `__LINKEDIT` segment. These fixups tell the dynamic linker (`dyld`) how to patch function variant pointers at load time so that each call site resolves to the best available implementation for the current hardware.

This command works in conjunction with `LC_FUNCTION_VARIANTS`, which describes the variant metadata. `LC_FUNCTION_VARIANT_FIXUPS` provides the actual fixup records that `dyld` processes to bind variant call sites to concrete function addresses.

This command was introduced in macOS 26 / iOS 19 and is not yet widely documented. The load command itself is a `linkedit_data_command` storing an offset and size into `__LINKEDIT`.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_FUNCTION_VARIANT_FIXUPS`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the fixup data in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the fixup data in bytes | 12 | 4 | `UInt32` |

**Fixed size:** 16 bytes

## See Also

- [LC_FUNCTION_VARIANTS](LC_FUNCTION_VARIANTS.md) -- Describes the function variants that these fixups resolve
- [LC_DYLD_CHAINED_FIXUPS](LC_DYLD_CHAINED_FIXUPS.md) -- General-purpose fixup mechanism that variant fixups complement

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_FUNCTION_VARIANT_FIXUPS.swift`](../../Sources/SwiftMachO/LoadCommands/LC_FUNCTION_VARIANT_FIXUPS.swift).
