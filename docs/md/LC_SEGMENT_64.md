# LC_SEGMENT_64

**Command ID:** `0x19`

Defines a 64-bit segment of the binary that the kernel or dynamic linker maps into a process's virtual address space at load time. This is the 64-bit counterpart to `LC_SEGMENT`, with wider address, size, and offset fields to support the larger address space.

Common segments include:

- `__PAGEZERO` -- Guard page at address 0 to catch NULL pointer dereferences
- `__TEXT` -- Executable code and read-only data
- `__DATA` -- Writable initialized data
- `__DATA_CONST` -- Read-only after initialization (e.g. Objective-C metadata)
- `__LINKEDIT` -- Metadata used by the dynamic linker (symbols, signatures, etc.)

Sections within a segment further subdivide the mapped region. The section array immediately follows the fixed segment fields in the load command.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_SEGMENT_64`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command including all section headers | 4 | 4 | `UInt32` |
| Name | Null-padded segment name (e.g. `__TEXT`) | 8 | 16 | `char[16]` |
| VM Address | Virtual memory address where this segment is mapped | 24 | 8 | `UInt64` |
| VM Size | Size of the segment in virtual memory (bytes) | 32 | 8 | `UInt64` |
| File Offset | Offset of the segment data in the file | 40 | 8 | `UInt64` |
| File Size | Size of the segment data in the file (bytes) | 48 | 8 | `UInt64` |
| Max Protections | Maximum permitted VM protection flags | 56 | 4 | `VM_PROT` |
| Initial Protections | Initial VM protection flags | 60 | 4 | `VM_PROT` |
| Number of Sections | Number of `Section64` entries that follow | 64 | 4 | `UInt32` |
| Flags | Segment flags | 68 | 4 | `SegmentFlags` |

**Fixed size:** 72 bytes (plus 80 bytes per section)

### Section64

Each section header immediately follows the segment fields. There are `nsects` entries. Compared to `Section32`, the address and size fields are 64-bit, and there is an additional `Reserved 3` field.

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Section Name | Null-padded section name (e.g. `__text`) | 0 | 16 | `char[16]` |
| Segment Name | Null-padded name of the parent segment | 16 | 16 | `char[16]` |
| Address | Virtual memory address of the section | 32 | 8 | `UInt64` |
| Size | Size of the section in bytes | 40 | 8 | `UInt64` |
| Offset | File offset of the section data | 48 | 4 | `UInt32` |
| Alignment | Section alignment as a power of 2 | 52 | 4 | `UInt32` |
| Relocations Offset | File offset of relocation entries | 56 | 4 | `UInt32` |
| Number of Relocations | Number of relocation entries | 60 | 4 | `UInt32` |
| Flags | Section type and attributes | 64 | 4 | `UInt32` |
| Reserved 1 | Reserved (used for indirect symbol index in some section types) | 68 | 4 | `UInt32` |
| Reserved 2 | Reserved (used for stub size in some section types) | 72 | 4 | `UInt32` |
| Reserved 3 | Reserved | 76 | 4 | `UInt32` |

**Section size:** 80 bytes

### VM_PROT

The `Max Protections` and `Initial Protections` fields are bitmasks of `VM_PROT` values:

| Flag | Value | Description |
|------|-------|-------------|
| `VM_PROT_READ` | `0x01` | Pages may be read |
| `VM_PROT_WRITE` | `0x02` | Pages may be written |
| `VM_PROT_EXECUTE` | `0x04` | Pages may be executed |

### SegmentFlags

| Flag | Value | Description |
|------|-------|-------------|
| `HIGH_VM` | `0x01` | Segment starts at the highest virtual address |
| `FIXED_VM_LIBRARY` | `0x02` | Segment has fixed virtual memory library |
| `NO_RELOCATIONS` | `0x04` | Segment has no relocations |
| `PROTECTED_V1` | `0x08` | Segment is protected (v1) |
| `READ_ONLY` | `0x10` | Segment is read-only after initial write |

## See Also

- [LC_SEGMENT](LC_SEGMENT.md) -- 32-bit variant

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SEGMENT_64.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SEGMENT_64.swift).
