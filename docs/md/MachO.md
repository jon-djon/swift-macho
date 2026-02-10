# MachO

The **MachO** struct is the main entry point for parsing Mach-O binary files. It represents a single Mach-O binary within a file, which could be a standalone executable, a library, or one architecture slice within a universal (fat) binary.

## Overview

Mach-O (Mach Object) is the executable file format used by macOS, iOS, and other Apple operating systems. A Mach-O file consists of:

1. **Magic number** - Identifies the file as Mach-O and specifies the architecture and byte order
2. **Header** - Contains metadata about the binary (CPU type, file type, number of load commands, etc.)
3. **Load commands** - Instructions for the dynamic linker and loader describing segments, dependencies, code signatures, etc.
4. **Data** - The actual code, data, and resources referenced by the load commands

## Structure

```swift
public struct MachO {
    public let magic: Magic              // Magic number identifying format
    public let header: MachOHeader       // Mach-O header with metadata
    public let loadCommands: [LoadCommandValue]  // Parsed load commands
    public let range: Range<Int>         // Byte range in source file
}
```

### Magic Numbers

The magic number determines the binary format:

| Magic | Value | Description |
|-------|-------|-------------|
| `macho32` | `0xFEEDFACE` | 32-bit big-endian |
| `macho64` | `0xFEEDFACF` | 64-bit big-endian |
| `macho32Swapped` | `0xCEFAEDFE` | 32-bit little-endian |
| `macho64Swapped` | `0xCFFAEDFE` | 64-bit little-endian |

### MachOHeader

The header contains essential metadata:

- **CPU type and subtype** - Architecture (ARM64, x86_64, etc.)
- **File type** - Executable, dynamic library, object file, etc.
- **Number of load commands** - How many load commands follow
- **Size of load commands** - Total byte size of all load commands
- **Flags** - Various binary attributes (PIE, TWOLEVEL, DYLDLINK, etc.)

## Load Commands

Load commands are instructions that tell the kernel and dynamic linker how to load and link the binary. They describe memory segments, dynamic libraries, code signatures, and more.

### Command Reference

| Command | ID | Documentation | Description |
|---------|-----|--------------|-------------|
| **Segment Commands** | | | |
| LC_SEGMENT | 0x01 | [LC_SEGMENT](LC_SEGMENT.md) | Defines a 32-bit memory segment to be loaded |
| LC_SEGMENT_64 | 0x19 | [LC_SEGMENT_64](LC_SEGMENT_64.md) | Defines a 64-bit memory segment to be loaded |
| **Symbol Table** | | | |
| LC_SYMTAB | 0x02 | [LC_SYMTAB](LC_SYMTAB.md) | Symbol table location and size |
| LC_DYSYMTAB | 0x0B | - | Dynamic symbol table information |
| **Dynamic Linking** | | | |
| LC_LOAD_DYLIB | 0x0C | [LC_LOAD_DYLIB](LC_LOAD_DYLIB.md) | Load a dynamic library |
| LC_LOAD_WEAK_DYLIB | 0x80000018 | [LC_LOAD_WEAK_DYLIB](LC_LOAD_WEAK_DYLIB.md) | Load a dynamic library weakly |
| LC_LOAD_DYLINKER | 0x0E | [LC_LOAD_DYLINKER](LC_LOAD_DYLINKER.md) | Specifies the dynamic linker to use |
| LC_ID_DYLINKER | 0x0F | - | Identifies this binary as a dynamic linker |
| LC_REEXPORT_DYLIB | 0x8000001F | - | Re-export symbols from another library |
| LC_LAZY_LOAD_DYLIB | 0x20 | - | Lazy load a dynamic library |
| LC_LOAD_UPWARD_DYLIB | 0x80000023 | - | Load library for upward dependencies |
| LC_DYLD_INFO | 0x22 | - | Compressed dyld information (legacy) |
| LC_DYLD_INFO_ONLY | 0x80000022 | - | Compressed dyld information |
| LC_DYLD_CHAINED_FIXUPS | 0x80000034 | [LC_DYLD_CHAINED_FIXUPS](LC_DYLD_CHAINED_FIXUPS.md) | Modern chained fixups for faster loading |
| LC_DYLD_EXPORTS_TRIE | 0x80000033 | - | Exported symbols in trie format |
| LC_DYLD_ENVIRONMENT | 0x27 | - | Environment variable for dyld |
| **Code Signature** | | | |
| LC_CODE_SIGNATURE | 0x1D | [LC_CODE_SIGNATURE](LC_CODE_SIGNATURE.md) | Code signature data location |
| LC_DYLIB_CODE_SIGN_DRS | 0x2B | - | Code signing DRs for libraries |
| **Function Information** | | | |
| LC_FUNCTION_STARTS | 0x26 | [LC_FUNCTION_STARTS](LC_FUNCTION_STARTS.md) | Table of function start addresses |
| LC_ATOM_INFO | 0x36 | [LC_ATOM_INFO](LC_ATOM_INFO.md) | Atom boundaries for linker optimization |
| LC_DATA_IN_CODE | 0x29 | - | Regions of code containing data |
| LC_LINKER_OPTIMIZATION_HINT | 0x2E | - | Hints for linker optimizations |
| LC_LINKER_OPTION | 0x2D | - | Linker options from object files |
| LC_FUNCTION_VARIANTS | 0x37 | - | Function variant information |
| LC_FUNCTION_VARIANT_FIXUPS | 0x38 | - | Fixups for function variants |
| **Version Information** | | | |
| LC_BUILD_VERSION | 0x32 | - | SDK and platform version information |
| LC_VERSION_MIN_MACOSX | 0x24 | - | Minimum macOS version required |
| LC_VERSION_MIN_IPHONEOS | 0x25 | - | Minimum iOS version required |
| LC_VERSION_MIN_TVOS | 0x2F | - | Minimum tvOS version required |
| LC_VERSION_MIN_WATCHOS | 0x30 | - | Minimum watchOS version required |
| LC_SOURCE_VERSION | 0x2A | - | Source code version |
| **Encryption** | | | |
| LC_ENCRYPTION_INFO | 0x21 | - | Encryption information for 32-bit |
| LC_ENCRYPTION_INFO_64 | 0x2C | - | Encryption information for 64-bit |
| **Main Entry** | | | |
| LC_MAIN | 0x80000028 | [LC_MAIN](LC_MAIN.md) | Entry point for executables |
| LC_UNIXTHREAD | 0x05 | - | Initial thread state (legacy) |
| LC_THREAD | 0x04 | - | Thread state (deprecated) |
| **Substructure** | | | |
| LC_SUB_FRAMEWORK | 0x12 | - | Identifies parent umbrella framework |
| LC_SUB_UMBRELLA | 0x11 | [LC_SUB_UMBRELLA](LC_SUB_UMBRELLA.md) | Identifies sub-umbrella framework |
| LC_SUB_CLIENT | 0x14 | - | Restricts clients that can link |
| LC_SUB_LIBRARY | 0x15 | - | Sub-library within umbrella |
| **Runtime Path** | | | |
| LC_RPATH | 0x8000001C | - | Runpath search path |
| **Miscellaneous** | | | |
| LC_UUID | 0x1B | - | Unique identifier for this binary |
| LC_SEGMENT_SPLIT_INFO | 0x1E | - | Split segment information |
| LC_NOTE | 0x31 | - | Arbitrary data note |
| LC_IDENT | 0x08 | - | Object identification (obsolete) |
| LC_FILESET_ENTRY | 0x80000035 | - | Fileset entry for kernel collections |
| LC_TARGET_TRIPLE | 0x39 | - | Target triple string |
| **Legacy/Obsolete** | | | |
| LC_SYMSEG | 0x03 | - | Symbol segment (obsolete) |
| LC_LOADFVMLIB | 0x06 | - | Load fixed VM shared library (obsolete) |
| LC_IDFVMLIB | 0x07 | - | Fixed VM shared library ID (obsolete) |
| LC_FVMFILE | 0x09 | - | Fixed VM file (obsolete) |
| LC_PREPAGE | 0x0A | - | Prepage command (obsolete) |
| LC_PREBOUND_DYLIB | 0x10 | - | Prebound library (obsolete) |
| LC_ROUTINES | 0x11 | - | Image routines 32-bit (obsolete) |
| LC_ROUTINES_64 | 0x1A | - | Image routines 64-bit (obsolete) |
| LC_TWOLEVEL_HINTS | 0x16 | - | Two-level namespace hints (obsolete) |
| LC_PREBIND_CKSUM | 0x17 | - | Prebind checksum (obsolete) |

### Required Commands

Some load commands are required for the dynamic linker:

- Commands with IDs that have the `LC_REQ_DYLD` bit set (0x80000000) **must** be understood by dyld
- If dyld encounters an unknown required command, it will refuse to load the binary
- This ensures forward compatibility - new features can be added without breaking old systems

## Common Patterns

### Finding Load Commands

```swift
// Get the first command of a specific type
let symtab = macho.getLoadCommandByType(.LC_SYMTAB)

// Get all commands of a specific type (e.g., all LC_LOAD_DYLIB)
let libraries = macho.getLoadCommandsByType(.LC_LOAD_DYLIB)
```

### Accessing Parsed Data

```swift
// Get code signature with parsed blobs
if let (command, signature) = macho.getSignature() {
    // Access entitlements, code directory, etc.
}

// Get entitlements directly
if let entitlements = macho.entitlements {
    // Array of entitlement key strings
}
```

### Working with Segments

Segments (LC_SEGMENT/LC_SEGMENT_64) define memory regions:

- **__TEXT** - Executable code and read-only data
- **__DATA** - Writable data (globals, statics)
- **__LINKEDIT** - Data for the dynamic linker (symbols, relocations, signatures)
- **__PAGEZERO** - Unmapped region to catch null pointer dereferences (executables only)

Each segment contains one or more sections with specific data types (e.g., `__TEXT,__text` for code, `__DATA,__data` for initialized data).

## File Types

The `header.filetype` field indicates the binary's purpose:

- **MH_EXECUTE** (0x2) - Executable program
- **MH_DYLIB** (0x6) - Dynamic library (.dylib)
- **MH_BUNDLE** (0x8) - Bundle/plugin
- **MH_DYLINKER** (0x7) - Dynamic linker (/usr/lib/dyld)
- **MH_OBJECT** (0x1) - Relocatable object file (.o)
- **MH_CORE** (0x4) - Core dump
- **MH_PRELOAD** (0x5) - Preloaded executable
- **MH_KEXT_BUNDLE** (0xB) - Kernel extension

## Parsing

The MachO struct is parsed from binary data:

```swift
let data = Data(contentsOf: URL(fileURLWithPath: "/path/to/binary"))
try data.withParserSpan { span in
    let macho = try MachO(parsing: &span, endianness: .little)
    // Use macho...
}
```

For fat/universal binaries, use `FatBinary` which contains multiple MachO slices for different architectures.

## Source

Defined in [`Sources/SwiftMachO/MachO.swift`](../../Sources/SwiftMachO/MachO.swift).

## See Also

- [FatBinary](FatBinary.md) - Universal binary containing multiple architectures
- [MachOHeader](MachOHeader.md) - Binary header structure
- [Load Command Reference](#command-reference) - Detailed documentation for each load command type

## References

- [OS X ABI Mach-O File Format Reference](https://github.com/apple-oss-distributions/xnu/blob/main/EXTERNAL_HEADERS/mach-o/loader.h) - Apple's official Mach-O header
- [Mach-O Programming Topics](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/MachOTopics/0-Introduction/introduction.html) - Apple's Mach-O guide (archived)
