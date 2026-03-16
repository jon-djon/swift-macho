# LC_DYLIB_CODE_SIGN_DRS

**Command ID:** `0x2B`

Points to code signing Designated Requirements (DRs) for dynamic libraries embedded in the `__LINKEDIT` segment. A Designated Requirement is a code signing expression that uniquely identifies a particular signing identity -- it answers the question "what makes this binary *this* binary?" independent of the certificate chain.

When the static linker (`ld`) builds an executable or dylib that depends on other dylibs, it can record each dependency's Designated Requirement in this load command. At runtime or during code signing verification, the system can check that the loaded libraries match the requirements captured at link time, providing an additional integrity guarantee beyond simple path-based loading.

This command is a `linkedit_data_command` that stores a file offset and size pointing into `__LINKEDIT`. The referenced data contains the serialized requirement expressions for the dependent libraries.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_DYLIB_CODE_SIGN_DRS`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the DRs data in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the DRs data in bytes | 12 | 4 | `UInt32` |

**Fixed size:** 16 bytes

## See Also

- [LC_CODE_SIGNATURE](LC_CODE_SIGNATURE.md) -- The main code signature data for this binary

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_DYLIB_CODE_SIGN_DRS.swift`](../../Sources/SwiftMachO/LoadCommands/LC_DYLIB_CODE_SIGN_DRS.swift).
