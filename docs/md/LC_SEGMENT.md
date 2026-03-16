# LC_SEGMENT

**Command ID:** `0x01`

Defines a 32-bit segment of the binary that the kernel or dynamic linker maps into a process's virtual address space at load time. Each segment describes a contiguous range of the file and the virtual memory region it should occupy, along with protection flags and an optional list of sections.

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
| Command ID | Load command identifier (`LC_SEGMENT`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command including all section headers | 4 | 4 | `UInt32` |
| Name | Null-padded segment name (e.g. `__TEXT`) | 8 | 16 | `char[16]` |
| VM Address | Virtual memory address where this segment is mapped | 24 | 4 | `UInt32` |
| VM Size | Size of the segment in virtual memory (bytes) | 28 | 4 | `UInt32` |
| File Offset | Offset of the segment data in the file | 32 | 4 | `UInt32` |
| File Size | Size of the segment data in the file (bytes) | 36 | 4 | `UInt32` |
| Max Protections | Maximum permitted VM protection flags | 40 | 4 | `VM_PROT` |
| Initial Protections | Initial VM protection flags | 44 | 4 | `VM_PROT` |
| Number of Sections | Number of `Section32` entries that follow | 48 | 4 | `UInt32` |
| Flags | Segment flags | 52 | 4 | `SegmentFlags` |

**Fixed size:** 56 bytes (plus 68 bytes per section)

### Section32

Each section header immediately follows the segment fields. There are `nsects` entries.

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Section Name | Null-padded section name (e.g. `__text`) | 0 | 16 | `char[16]` |
| Segment Name | Null-padded name of the parent segment | 16 | 16 | `char[16]` |
| Address | Virtual memory address of the section | 32 | 4 | `UInt32` |
| Size | Size of the section in bytes | 36 | 4 | `UInt32` |
| Offset | File offset of the section data | 40 | 4 | `UInt32` |
| Alignment | Section alignment as a power of 2 | 44 | 4 | `UInt32` |
| Relocations Offset | File offset of relocation entries | 48 | 4 | `UInt32` |
| Number of Relocations | Number of relocation entries | 52 | 4 | `UInt32` |
| Flags | Section type and attributes | 56 | 4 | `UInt32` |
| Reserved 1 | Reserved (used for indirect symbol index in some section types) | 60 | 4 | `UInt32` |
| Reserved 2 | Reserved (used for stub size in some section types) | 64 | 4 | `UInt32` |

**Section size:** 68 bytes

## See Also

- [LC_SEGMENT_64](LC_SEGMENT_64.md) -- 64-bit variant with wider address and size fields

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_SEGMENT.swift`](../../Sources/SwiftMachO/LoadCommands/LC_SEGMENT.swift).
