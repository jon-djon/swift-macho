# LC_VERSION_MIN_MACOSX

**Command ID:** `0x24`

Specifies the minimum version of macOS required to run this binary, along with the SDK version it was built against. This is a legacy command -- modern binaries use `LC_BUILD_VERSION` instead, which covers all Apple platforms in a single command.

The kernel checks this version at load time and refuses to run the binary if the system version is older than the minimum. `dyld` and frameworks also use the SDK version to enable compatibility behaviors for binaries built against older SDKs.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_VERSION_MIN_MACOSX`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Version | Minimum macOS version required (e.g. 10.13.0) | 8 | 4 | `SemanticVersion` |
| SDK | SDK version the binary was built against | 12 | 4 | `SemanticVersion` |

**Fixed size:** 16 bytes

## See Also

- [LC_BUILD_VERSION](LC_BUILD_VERSION.md) -- Modern replacement covering all platforms
- [LC_VERSION_MIN_IPHONEOS](LC_VERSION_MIN_IPHONEOS.md) -- iOS equivalent
- [LC_VERSION_MIN_TVOS](LC_VERSION_MIN_TVOS.md) -- tvOS equivalent
- [LC_VERSION_MIN_WATCHOS](LC_VERSION_MIN_WATCHOS.md) -- watchOS equivalent

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_VERSION_MIN_MACOSX.swift`](../../Sources/SwiftMachO/LoadCommands/LC_VERSION_MIN_MACOSX.swift).
