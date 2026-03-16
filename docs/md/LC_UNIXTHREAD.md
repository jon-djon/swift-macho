# LC_UNIXTHREAD

**Command ID:** `0x05`

Specifies the initial thread state for a Unix process. The command defines the register values -- including the program counter (entry point) -- for the main thread when the kernel starts the process. This is the legacy way to define an executable's entry point, replaced by `LC_MAIN` starting with OS X 10.8.

Unlike `LC_MAIN`, which stores a simple offset relative to `__TEXT`, `LC_UNIXTHREAD` contains a full machine-specific register state. The kernel loads these register values directly into the thread before it begins executing. In practice, only the instruction pointer register (`rip`, `eip`, or `pc`) and stack pointer are meaningful -- all other registers are typically zero.

The command begins with a `flavor` field that identifies the CPU architecture and register set, followed by a `count` of 32-bit words in the thread state data. The thread state structure that follows is architecture-specific.

`LC_UNIXTHREAD` is still found in the kernel itself, `dyld`, and some legacy executables. Modern user-space binaries use `LC_MAIN` exclusively.

## Fields

| Name | Description | Offset | Size | Type |
|------|-------------|--------|------|------|
| Command ID | Load command identifier (`LC_UNIXTHREAD`) | 0 | 4 | `UInt32` |
| Command Size | Total size of this load command (including thread state) | 4 | 4 | `UInt32` |
| Flavor | Thread state flavor identifying the architecture (see below) | 8 | 4 | `Flavor` |
| Count | Number of 32-bit words in the thread state data | 12 | 4 | `UInt32` |
| Thread State | Architecture-specific register state | 16 | variable | see below |

**Minimum size:** 16 bytes (header + flavor + count, before thread state)

### Flavor

| Name | Value | Description |
|------|-------|-------------|
| `x86_THREAD_STATE32` | `1` | x86 32-bit thread state |
| `x86_FLOAT_STATE32` | `2` | x86 32-bit float state |
| `x86_EXCEPTION_STATE32` | `3` | x86 32-bit exception state |
| `x86_THREAD_STATE64` | `4` | x86-64 thread state |
| `x86_FLOAT_STATE64` | `5` | x86-64 float state |
| `x86_EXCEPTION_STATE64` | `6` | x86-64 exception state |
| `x86_THREAD_STATE` | `7` | x86 universal thread state |
| `x86_FLOAT_STATE` | `8` | x86 universal float state |
| `x86_EXCEPTION_STATE` | `9` | x86 universal exception state |
| `x86_DEBUG_STATE32` | `10` | x86 32-bit debug state |
| `x86_DEBUG_STATE64` | `11` | x86-64 debug state |
| `x86_DEBUG_STATE` | `12` | x86 universal debug state |
| `ARM_THREAD_STATE` | `1001` | ARM 32-bit thread state |
| `ARM_THREAD_STATE64` | `1006` | ARM64 thread state |

## Thread State Structures

### x86-64 (ThreadState64)

21 registers, each 8 bytes. The entry point is in `rip`.

| Register | Offset | Size | Description |
|----------|--------|------|-------------|
| `rax`-`rdx` | 0 | 32 | General-purpose registers |
| `rdi`, `rsi` | 32 | 16 | Argument registers |
| `rbp` | 48 | 8 | Frame pointer |
| `rsp` | 56 | 8 | Stack pointer |
| `r8`-`r15` | 64 | 64 | Extended general-purpose registers |
| `rip` | 128 | 8 | Instruction pointer (entry point) |
| `rflags` | 136 | 8 | CPU flags |
| `cs`, `fs`, `gs` | 144 | 24 | Segment registers |

**Total size:** 168 bytes

### x86 32-bit (ThreadState32)

16 registers, each 4 bytes. The entry point is in `eip`.

| Register | Offset | Size | Description |
|----------|--------|------|-------------|
| `eax`-`edx` | 0 | 16 | General-purpose registers |
| `edi`, `esi` | 16 | 8 | Index registers |
| `ebp` | 24 | 4 | Frame pointer |
| `esp` | 28 | 4 | Stack pointer |
| `ss` | 32 | 4 | Stack segment |
| `eflags` | 36 | 4 | CPU flags |
| `eip` | 40 | 4 | Instruction pointer (entry point) |
| `cs`-`gs` | 44 | 20 | Segment registers |

**Total size:** 64 bytes

### ARM64 (ARM64ThreadState)

33 64-bit registers plus `cpsr` and padding. The entry point is in `pc`.

| Register | Offset | Size | Description |
|----------|--------|------|-------------|
| `x0`-`x28` | 0 | 232 | General-purpose registers |
| `fp` (x29) | 232 | 8 | Frame pointer |
| `lr` (x30) | 240 | 8 | Link register |
| `sp` | 248 | 8 | Stack pointer |
| `pc` | 256 | 8 | Program counter (entry point) |
| `cpsr` | 264 | 4 | Current program status register |
| `pad` | 268 | 4 | Padding for alignment |

**Total size:** 272 bytes

## See Also

- [LC_MAIN](LC_MAIN.md) -- Modern replacement; stores just an offset and stack size
- [LC_THREAD](LC_THREAD.md) -- Same structure but does not set the program counter

## Source

Defined in [`Sources/SwiftMachO/LoadCommands/LC_UNIXTHREAD.swift`](../../Sources/SwiftMachO/LoadCommands/LC_UNIXTHREAD.swift).
