# Load Commands

All structs conforming to the `LoadCommand` protocol.

| Struct | Protocols | Source |
|--------|-----------|--------|
| `LC_ATOM_INFO` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_ATOM_INFO.swift](../../Sources/SwiftMachO/LoadCommands/LC_ATOM_INFO.swift) |
| `LC_BUILD_VERSION` | `LoadCommand` | [LC_BUILD_VERSION.swift](../../Sources/SwiftMachO/LoadCommands/LC_BUILD_VERSION.swift) |
| `LC_CODE_SIGNATURE` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_CODE_SIGNATURE.swift](../../Sources/SwiftMachO/LoadCommands/LC_CODE_SIGNATURE/LC_CODE_SIGNATURE.swift) |
| `LC_DATA_IN_CODE` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_DATA_IN_CODE.swift](../../Sources/SwiftMachO/LoadCommands/LC_DATA_IN_CODE.swift) |
| `LC_DYLD_CHAINED_FIXUPS` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_DYLD_CHAINED_FIXUPS.swift](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_CHAINED_FIXUPS/LC_DYLD_CHAINED_FIXUPS.swift) |
| `LC_DYLD_ENVIRONMENT` | `LoadCommand` | [LC_DYLD_ENVIRONMENT.swift](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_ENVIRONMENT.swift) |
| `LC_DYLD_EXPORTS_TRIE` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_DYLD_EXPORTS_TRIE.swift](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_EXPORTS_TRIE.swift) |
| `LC_DYLD_INFO` | `LoadCommand` | [LC_DYLD_INFO.swift](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_INFO.swift) |
| `LC_DYLD_INFO_ONLY` | `LoadCommand` | [LC_DYLD_INFO_ONLY.swift](../../Sources/SwiftMachO/LoadCommands/LC_DYLD_INFO_ONLY.swift) |
| `LC_DYLIB_CODE_SIGN_DRS` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_DYLIB_CODE_SIGN_DRS.swift](../../Sources/SwiftMachO/LoadCommands/LC_DYLIB_CODE_SIGN_DRS.swift) |
| `LC_DYSYMTAB` | `LoadCommand` | [LC_DYSYMTAB.swift](../../Sources/SwiftMachO/LoadCommands/LC_DYSYMTAB.swift) |
| `LC_ENCRYPTION_INFO` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_ENCRYPTION_INFO.swift](../../Sources/SwiftMachO/LoadCommands/LC_ENCRYPTION_INFO.swift) |
| `LC_ENCRYPTION_INFO_64` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_ENCRYPTION_INFO_64.swift](../../Sources/SwiftMachO/LoadCommands/LC_ENCRYPTION_INFO_64.swift) |
| `LC_FILESET_ENTRY` | `LoadCommand` | [LC_FILESET_ENTRY.swift](../../Sources/SwiftMachO/LoadCommands/LC_FILESET_ENTRY.swift) |
| `LC_FUNCTION_STARTS` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_FUNCTION_STARTS.swift](../../Sources/SwiftMachO/LoadCommands/LC_FUNCTION_STARTS.swift) |
| `LC_FUNCTION_VARIANT_FIXUPS` | `LoadCommand` | [LC_FUNCTION_VARIANT_FIXUPS.swift](../../Sources/SwiftMachO/LoadCommands/LC_FUNCTION_VARIANT_FIXUPS.swift) |
| `LC_FUNCTION_VARIANTS` | `LoadCommand` | [LC_FUNCTION_VARIANTS.swift](../../Sources/SwiftMachO/LoadCommands/LC_FUNCTION_VARIANTS.swift) |
| `LC_FVMFILE` | `LoadCommand` | [LC_FVMFILE.swift](../../Sources/SwiftMachO/LoadCommands/LC_FVMFILE.swift) |
| `LC_ID_DYLINKER` | `LoadCommand` | [LC_ID_DYLINKER.swift](../../Sources/SwiftMachO/LoadCommands/LC_ID_DYLINKER.swift) |
| `LC_IDENT` | `LoadCommand` | [LC_IDENT.swift](../../Sources/SwiftMachO/LoadCommands/LC_IDENT.swift) |
| `LC_IDFVMLIB` | `LoadCommand` | [LC_IDFVMLIB.swift](../../Sources/SwiftMachO/LoadCommands/LC_IDFVMLIB.swift) |
| `LC_LAZY_LOAD_DYLIB` | `LoadCommand` | [LC_LAZY_LOAD_DYLIB.swift](../../Sources/SwiftMachO/LoadCommands/LC_LAZY_LOAD_DYLIB.swift) |
| `LC_LINKER_OPTIMIZATION_HINT` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_LINKER_OPTIMIZATION_HINT.swift](../../Sources/SwiftMachO/LoadCommands/LC_LINKER_OPTIMIZATION_HINT.swift) |
| `LC_LINKER_OPTION` | `LoadCommand` | [LC_LINKER_OPTION.swift](../../Sources/SwiftMachO/LoadCommands/LC_LINKER_OPTION.swift) |
| `LC_LOAD_DYLIB` | `LoadCommand` | [LC_LOAD_DYLIB.swift](../../Sources/SwiftMachO/LoadCommands/LC_LOAD_DYLIB.swift) |
| `LC_LOAD_DYLINKER` | `LoadCommand` | [LC_LOAD_DYLINKER.swift](../../Sources/SwiftMachO/LoadCommands/LC_LOAD_DYLINKER.swift) |
| `LC_LOAD_UPWARD_DYLIB` | `LoadCommand` | [LC_LOAD_UPWARD_DYLIB .swift](../../Sources/SwiftMachO/LoadCommands/LC_LOAD_UPWARD_DYLIB%20.swift) |
| `LC_LOAD_WEAK_DYLIB` | `LoadCommand` | [LC_LOAD_WEAK_DYLIB.swift](../../Sources/SwiftMachO/LoadCommands/LC_LOAD_WEAK_DYLIB.swift) |
| `LC_LOADFVMLIB` | `LoadCommand` | [LC_LOADFVMLIB.swift](../../Sources/SwiftMachO/LoadCommands/LC_LOADFVMLIB.swift) |
| `LC_MAIN` | `LoadCommand` | [LC_MAIN.swift](../../Sources/SwiftMachO/LoadCommands/LC_MAIN.swift) |
| `LC_NOTE` | `LoadCommand` | [LC_NOTE.swift](../../Sources/SwiftMachO/LoadCommands/LC_NOTE.swift) |
| `LC_PREBIND_CKSUM` | `LoadCommand` | [LC_PREBIND_CKSUM.swift](../../Sources/SwiftMachO/LoadCommands/LC_PREBIND_CKSUM.swift) |
| `LC_PREBOUND_DYLIB` | `LoadCommand` | [LC_PREBOUND_DYLIB.swift](../../Sources/SwiftMachO/LoadCommands/LC_PREBOUND_DYLIB.swift) |
| `LC_PREPAGE` | `LoadCommand` | [LC_PREPAGE.swift](../../Sources/SwiftMachO/LoadCommands/LC_PREPAGE.swift) |
| `LC_REEXPORT_DYLIB` | `LoadCommand` | [LC_REEXPORT_DYLIB.swift](../../Sources/SwiftMachO/LoadCommands/LC_REEXPORT_DYLIB.swift) |
| `LC_ROUTINES` | `LoadCommand` | [LC_ROUTINES.swift](../../Sources/SwiftMachO/LoadCommands/LC_ROUTINES.swift) |
| `LC_ROUTINES_64` | `LoadCommand` | [LC_ROUTINES_64.swift](../../Sources/SwiftMachO/LoadCommands/LC_ROUTINES_64.swift) |
| `LC_RPATH` | `LoadCommand` | [LC_RPATH.swift](../../Sources/SwiftMachO/LoadCommands/LC_RPATH.swift) |
| `LC_SEGMENT` | `LoadCommand` | [LC_SEGMENT.swift](../../Sources/SwiftMachO/LoadCommands/LC_SEGMENT.swift) |
| `LC_SEGMENT_64` | `LoadCommand` | [LC_SEGMENT_64.swift](../../Sources/SwiftMachO/LoadCommands/LC_SEGMENT_64.swift) |
| `LC_SEGMENT_SPLIT_INFO` | `LoadCommand`, `LoadCommandLinkEdit` | [LC_SEGMENT_SPLIT_INFO.swift](../../Sources/SwiftMachO/LoadCommands/LC_SEGMENT_SPLIT_INFO.swift) |
| `LC_SOURCE_VERSION` | `LoadCommand` | [LC_SOURCE_VERSION.swift](../../Sources/SwiftMachO/LoadCommands/LC_SOURCE_VERSION.swift) |
| `LC_SUB_CLIENT` | `LoadCommand` | [LC_SUB_CLIENT.swift](../../Sources/SwiftMachO/LoadCommands/LC_SUB_CLIENT.swift) |
| `LC_SUB_FRAMEWORK` | `LoadCommand` | [LC_SUB_FRAMEWORK.swift](../../Sources/SwiftMachO/LoadCommands/LC_SUB_FRAMEWORK.swift) |
| `LC_SUB_LIBRARY` | `LoadCommand` | [LC_SUB_LIBRARY.swift](../../Sources/SwiftMachO/LoadCommands/LC_SUB_LIBRARY.swift) |
| `LC_SUB_UMBRELLA` | `LoadCommand` | [LC_SUB_UMBRELLA.swift](../../Sources/SwiftMachO/LoadCommands/LC_SUB_UMBRELLA.swift) |
| `LC_SYMSEG` | `LoadCommand` | [LC_SYMSEG.swift](../../Sources/SwiftMachO/LoadCommands/LC_SYMSEG.swift) |
| `LC_SYMTAB` | `LoadCommand` | [LC_SYMTAB.swift](../../Sources/SwiftMachO/LoadCommands/LC_SYMTAB/LC_SYMTAB.swift) |
| `LC_TARGET_TRIPLE` | `LoadCommand` | [LC_TARGET_TRIPLE.swift](../../Sources/SwiftMachO/LoadCommands/LC_TARGET_TRIPLE.swift) |
| `LC_THREAD` | `LoadCommand` | [LC_THREAD.swift](../../Sources/SwiftMachO/LoadCommands/LC_THREAD.swift) |
| `LC_TWOLEVEL_HINTS` | `LoadCommand` | [LC_TWOLEVEL_HINTS.swift](../../Sources/SwiftMachO/LoadCommands/LC_TWOLEVEL_HINTS.swift) |
| `LC_UNIXTHREAD` | `LoadCommand` | [LC_UNIXTHREAD.swift](../../Sources/SwiftMachO/LoadCommands/LC_UNIXTHREAD.swift) |
| `LC_UUID` | `LoadCommand` | [LC_UUID.swift](../../Sources/SwiftMachO/LoadCommands/LC_UUID.swift) |
| `LC_VERSION_MIN_IPHONEOS` | `LoadCommand` | [LC_VERSION_MIN_IPHONEOS.swift](../../Sources/SwiftMachO/LoadCommands/LC_VERSION_MIN_IPHONEOS.swift) |
| `LC_VERSION_MIN_MACOSX` | `LoadCommand` | [LC_VERSION_MIN_MACOSX.swift](../../Sources/SwiftMachO/LoadCommands/LC_VERSION_MIN_MACOSX.swift) |
| `LC_VERSION_MIN_TVOS` | `LoadCommand` | [LC_VERSION_MIN_TVOS.swift](../../Sources/SwiftMachO/LoadCommands/LC_VERSION_MIN_TVOS.swift) |
| `LC_VERSION_MIN_WATCHOS` | `LoadCommand` | [LC_VERSION_MIN_WATCHOS.swift](../../Sources/SwiftMachO/LoadCommands/LC_VERSION_MIN_WATCHOS.swift) |
