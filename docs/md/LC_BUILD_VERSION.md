# LC_BUILD_VERSION

**Command ID:** `0x32`

Specifies the target platform, minimum OS version, SDK version, and build tools used to create the binary. This is the modern, unified replacement for the per-platform `LC_VERSION_MIN_*` commands and provides a single command that covers all Apple platforms, including newer ones like DriverKit, visionOS, and Mac Catalyst.

The kernel and `dyld` use the platform and minimum OS version to determine whether the binary is compatible with the running system. Xcode and other tools use the SDK version to apply appropriate compatibility behaviors. The build tool entries record which compiler, linker, and Swift versions produced the binary, which is useful for diagnostics and debugging.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_BUILD_VERSION`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including tool entries) | 4 | 4 | `UInt32` |
| Platform | Target platform identifier (see below) | 8 | 4 | `PlatformEnum` |
| Min OS | Minimum OS version required to run this binary | 12 | 4 | `SemanticVersion` |
| SDK | SDK version the binary was built against | 16 | 4 | `SemanticVersion` |
| Number of Tools | Number of build tool entries that follow | 20 | 4 | `UInt32` |

**Fixed size:** 24 bytes (plus 8 bytes per tool entry)

### BuildToolVersion

Each tool entry immediately follows the fixed fields.

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Tool | Build tool identifier (see below) | 0 | 4 | `ToolEnum` |
| Version | Tool version | 4 | 4 | `SemanticVersion` |

**Entry size:** 8 bytes

### PlatformEnum

| Name | Value | Description |
|------|-------|-------------|
| `PLATFORM_UNKNOWN` | `0` | Unknown platform |
| `PLATFORM_MACOS` | `1` | macOS |
| `PLATFORM_IOS` | `2` | iOS |
| `PLATFORM_TVOS` | `3` | tvOS |
| `PLATFORM_WATCHOS` | `4` | watchOS |
| `PLATFORM_BRIDGEOS` | `5` | bridgeOS |
| `PLATFORM_MACCATALYST` | `6` | Mac Catalyst |
| `PLATFORM_IOSSIMULATOR` | `7` | iOS Simulator |
| `PLATFORM_TVOSSIMULATOR` | `8` | tvOS Simulator |
| `PLATFORM_WATCHOSSIMULATOR` | `9` | watchOS Simulator |
| `PLATFORM_DRIVERKIT` | `10` | DriverKit |
| `PLATFORM_REALITYOS` | `11` | visionOS |
| `PLATFORM_REALITYOSSIMULATOR` | `12` | visionOS Simulator |
| `PLATFORM_FIRMWARE` | `13` | Firmware |
| `PLATFORM_SEPOS` | `14` | Secure Enclave OS |
| `PLATFORM_MACOS_EXCLAVECORE` | `15` | macOS Exclave Core |
| `PLATFORM_MACOS_EXCLAVEKIT` | `16` | macOS Exclave Kit |
| `PLATFORM_IOS_EXCLAVECORE` | `17` | iOS Exclave Core |
| `PLATFORM_IOS_EXCLAVEKIT` | `18` | iOS Exclave Kit |
| `PLATFORM_TVOS_EXCLAVECORE` | `19` | tvOS Exclave Core |
| `PLATFORM_TVOS_EXCLAVEKIT` | `20` | tvOS Exclave Kit |
| `PLATFORM_WATCHOS_EXCLAVECORE` | `21` | watchOS Exclave Core |
| `PLATFORM_WATCHOS_EXCLAVEKIT` | `22` | watchOS Exclave Kit |

### ToolEnum

| Name | Value | Description |
|------|-------|-------------|
| `TOOL_NONE` | `0` | No tool |
| `TOOL_CLANG` | `1` | Clang compiler |
| `TOOL_SWIFT` | `2` | Swift compiler |
| `TOOL_LD` | `3` | Apple linker (ld64) |
| `TOOL_LLD` | `4` | LLVM linker (lld) |

## See Also

- [LC_VERSION_MIN_MACOSX](LC_VERSION_MIN_MACOSX.md) -- Legacy macOS-specific version command
- [LC_SOURCE_VERSION](LC_SOURCE_VERSION.md) -- Source code version (separate from build/SDK versions)

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_BUILD_VERSION.swift`](../../Sources/SwiftMachO/LoadCommands/LC_BUILD_VERSION.swift).
