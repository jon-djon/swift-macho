# LC_LINKER_OPTION

**Command ID:** `0x2D`

Embeds linker flags directly in an object file so that the static linker (`ld`) processes them automatically when linking. This allows compilers and build systems to record link-time dependencies (such as `-framework` or `-l` flags) at compile time, eliminating the need to specify them separately in the link command.

Swift and Clang use this command to implement auto-linking. When source code imports a module or uses `#pragma comment(lib, ...)`, the compiler emits an `LC_LINKER_OPTION` in the `.o` file containing the appropriate linker flags. When `ld` processes the object file, it reads these commands and acts on them as if the flags had been passed on the command line.

Each command contains a count followed by that many null-terminated strings, representing one complete linker invocation fragment (e.g. `-framework`, `CoreFoundation` as two strings).

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_LINKER_OPTION`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including option strings) | 4 | 4 | `UInt32` |
| Option Count | Number of null-terminated option strings that follow | 8 | 4 | `UInt32` |
| Options | Consecutive null-terminated strings (e.g. `-framework`, `CoreFoundation`) | 12 | variable | `String[]` |

**Minimum size:** 12 bytes (header + fixed fields, before option strings)

## Example

A Swift file containing `import Foundation` produces an `LC_LINKER_OPTION` with two strings:

```
Option 0: "-framework"
Option 1: "Foundation"
```

This causes `ld` to automatically link against `Foundation.framework` without an explicit `-framework Foundation` on the link command line.

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_LINKER_OPTION.swift`](../../Sources/SwiftMachO/LoadCommands/LC_LINKER_OPTION.swift).
