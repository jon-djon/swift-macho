# LC_ENCRYPTION_INFO

**Command ID:** `0x21`

Identifies an encrypted region of a 32-bit Mach-O binary. This command is used by Apple's FairPlay DRM system to mark the `__TEXT` segment (or a portion of it) as encrypted in App Store applications. When the binary is loaded, the kernel decrypts the region in memory before execution begins.

A `cryptID` of `0` means the binary is not currently encrypted -- this is the state after the App Store delivers the binary to a device and the DRM layer has already decrypted it on disk (or when inspecting a decrypted dump). A `cryptID` of `1` indicates active FairPlay encryption.

The offset and size fields point to the encrypted region within the file, typically covering the executable code in the `__TEXT` segment.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_ENCRYPTION_INFO`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (20 bytes) | 4 | 4 | `UInt32` |
| Crypt Offset | File offset of the encrypted region | 8 | 4 | `UInt32` |
| Crypt Size | Size of the encrypted region in bytes | 12 | 4 | `UInt32` |
| Crypt ID | Encryption system identifier (see below) | 16 | 4 | `CryptID` |

**Fixed size:** 20 bytes

### CryptID

| Name | Value | Description |
|------|-------|-------------|
| `notEncrypted` | `0` | Binary is not encrypted (or has been decrypted) |
| `encrypted` | `1` | FairPlay DRM encryption |

## See Also

- [LC_ENCRYPTION_INFO_64](LC_ENCRYPTION_INFO_64.md) -- 64-bit variant with an additional padding field

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_ENCRYPTION_INFO.swift`](../../Sources/SwiftMachO/LoadCommands/LC_ENCRYPTION_INFO.swift).
