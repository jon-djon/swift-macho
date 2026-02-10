# LC_ATOM_INFO

**Command ID:** `0x36`

Points to a table of atom info data stored in the `__LINKEDIT` segment. This information describes the boundaries of atoms (indivisible code or data blocks) in the `__TEXT` section, which helps the linker perform optimizations and dead code stripping.

An atom is the smallest unit of code or data that can be independently linked. By defining atom boundaries, the linker can:
- Perform more aggressive dead code elimination
- Optimize code layout and reduce binary size
- Better understand code dependencies for incremental linking
- Support advanced optimization techniques

The load command itself is a `linkedit_data_command` that stores an offset and size pointing into `__LINKEDIT`. The atom info data is typically encoded as a series of offsets and sizes that define each atom's location within the binary.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_ATOM_INFO`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (16 bytes) | 4 | 4 | `UInt32` |
| Data Offset | File offset of the atom info data in `__LINKEDIT` | 8 | 4 | `UInt32` |
| Data Size | Size of the atom info data in bytes | 12 | 4 | `UInt32` |

**Total size:** 16 bytes

## Usage

LC_ATOM_INFO is used by newer versions of the linker to enable advanced optimization and linking techniques. It's most commonly found in object files and static libraries rather than final executables, as the atom boundaries are primarily useful during the link phase.

The command was introduced to support more granular dead code stripping and link-time optimizations, particularly for Swift and modern Objective-C code where fine-grained code organization is important for binary size optimization.

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_ATOM_INFO.swift`](../../Sources/SwiftMachO/LoadCommands/LC_ATOM_INFO.swift).
