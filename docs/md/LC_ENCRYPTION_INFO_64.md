# LC_ENCRYPTION_INFO_64

**Command ID:** `0x2C`

Identifies an encrypted region of a 64-bit Mach-O binary. This is the 64-bit counterpart to `LC_ENCRYPTION_INFO`, with an additional padding field for alignment. It is used by Apple's FairPlay DRM system to mark the `__TEXT` segment as encrypted in App Store applications.

A `cryptID` of `0` means the binary is not currently encrypted -- this is the state after the App Store delivers the binary to a device and the DRM layer has already decrypted it on disk (or when inspecting a decrypted dump). A `cryptID` of `1` indicates active FairPlay encryption.

The offset and size fields point to the encrypted region within the file, typically covering the executable code in the `__TEXT` segment.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_ENCRYPTION_INFO_64`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (24 bytes) | 4 | 4 | `UInt32` |
| Crypt Offset | File offset of the encrypted region | 8 | 4 | `UInt32` |
| Crypt Size | Size of the encrypted region in bytes | 12 | 4 | `UInt32` |
| Crypt ID | Encryption system identifier (see below) | 16 | 4 | `CryptID` |
| Pad | Padding for 64-bit alignment (should be 0) | 20 | 4 | `UInt32` |

**Fixed size:** 24 bytes

### CryptID

| Name | Value | Description |
|------|-------|-------------|
| `notEncrypted` | `0` | Binary is not encrypted (or has been decrypted) |
| `encrypted` | `1` | FairPlay DRM encryption |

## See Also

- [LC_ENCRYPTION_INFO](LC_ENCRYPTION_INFO.md) -- 32-bit variant without the padding field

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_ENCRYPTION_INFO_64.swift`](../../Sources/SwiftMachO/LoadCommands/LC_ENCRYPTION_INFO_64.swift).
