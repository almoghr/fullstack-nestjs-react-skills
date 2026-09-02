---
name: cpp-decompile
description: >-
  Systematic workflow for reverse-engineering, disassembling, and reconstructing
  high-level, human-readable C++ source code from compiled binaries (Windows PE/DLL,
  macOS Mach-O/dylib, and Linux ELF). Use whenever tasked with decompiling, reverse
  engineering, or reconstructing C/C++ logic from binary files.
---

# C++ Binary Decompilation & Reconstruction Workflow

This skill defines the end-to-end procedure for reversing compiled binaries into clean, compilable, and functionally equivalent C++ source code.

---

## Workflow Overview

Follow this 6-stage pipeline systematically:

```
[1. Binary Triage] ──> [2. Symbol & ABI] ──> [3. Disassembly] ──> [4. C++ Lifting] ──> [5. Struct & Type Recovery] ──> [6. Validation]
```

---

## Stage 1: Binary Identification & Triage

Run the inspection script to extract file format, CPU architecture, bitness, endianness, and external dependencies:

```bash
./scripts/inspect_binary.sh <path-to-binary>
```

Key determinations:
- **Binary Format**: Windows PE (`.dll`/`.exe`), macOS Mach-O (`.dylib`), or Linux ELF (`.so`).
- **Architecture**: `x86-64`, `ARM64` (`aarch64`), or `x86` (32-bit).
- **Linking**: Dynamically linked or statically linked CRT/libstdc++.

---

## Stage 2: Symbol & Export Table Analysis

1. **Locate Public API Boundaries**:
   Identify all exported entry points from the export table (`.edata` or dynamic symbol table):
   - For Windows PE: Check ordinal numbers, hint names, and function RVAs.
   - Look for `extern "C"` unmangled names vs. Itanium/MSVC C++ mangled symbols.
   
2. **Demangle C++ Names** (if present):
   ```bash
   c++filt <mangled-symbol>
   # Example: _Z19splitBySpecialChars... -> splitBySpecialChars(...)
   ```

3. **Inspect String Literals**:
   Identify constant strings, error messages, format specifiers, and default delimiters in `.rdata` / `__cstring` sections.

---

## Stage 3: Targeted Function Disassembly

Extract the disassembly for specific target functions using the helper script:

```bash
./scripts/disassemble_func.sh <path-to-binary> <function-name>
```

Identify the calling convention and parameter mapping using [calling_conventions.md](./references/calling_conventions.md):
- **Windows x64**: `RCX` (1st), `RDX` (2nd), `R8` (3rd), `R9` (4th), return in `RAX`.
- **System V AMD64 (Linux/macOS)**: `RDI` (1st), `RSI` (2nd), `RDX` (3rd), `RCX` (4th), return in `RAX`.
- **ARM64**: `X0` - `X7` (parameters), return in `X0`.

---

## Stage 4: Control Flow Lifting & Idiom Recognition

Translate assembly constructs into high-level C++ using the pattern catalog in [decompile_patterns.md](./references/decompile_patterns.md):

1. **Null Checks & Guards**:
   - `test %reg, %reg; je <addr>` $\rightarrow$ `if (ptr == nullptr) return ...;`
2. **Loops & Iteration**:
   - Trace back-edges in jumps (`jmp`, `jne`, `jl`, `jg`) to identify `for`, `while`, and `do-while` loops.
3. **Memory Management**:
   - Identify heap allocation calls: `malloc()`, `calloc()`, or `operator new()`.
   - Ensure matching deallocation functions (`free()`, `delete`) are paired in the reconstructed API.
4. **Data Structures**:
   - Reconstruct standard library types (`std::string`, `std::vector`, `std::unordered_set`) by analyzing member offset patterns (e.g., 3-pointer vector layouts, 15-byte SSO strings).

---

## Stage 5: C++ Reconstruction Best Practices

When authoring the reconstructed `.cpp` file:

1. **Preserve ABI & Linkage**:
   - If the binary exported C symbols, maintain `extern "C"` and appropriate calling conventions (`__stdcall` / `DLL_API`).
2. **Memory Safety & Ownership**:
   - Explicitly document who owns returned buffers (caller vs. callee).
   - Provide safe buffer-capacity versions where appropriate.
3. **Avoid Hardcoded Magic Numbers**:
   - Extract constants recovered from the disassembly into named `const` or `constexpr` variables.
4. **Clean Code over Literal Machine Artifacts**:
   - Do NOT produce raw decompiler junk (e.g. `uVar1`, `puVar2 = (int *)0x0`). Lift the code into idiomatic, readable, type-safe C++17.

---

## Stage 6: Dynamic Verification & Validation

Never consider decompilation complete without verification:

1. **Write a Verification Suite**:
   Include a test `main()` in the reconstructed file (or a test runner) that covers:
   - Happy path with standard inputs.
   - Edge cases (null pointers, empty strings, consecutive delimiters).
   - Buffer bounds limits and overflow prevention.
2. **Compile and Execute**:
   ```bash
   clang++ -std=c++17 -Wall -Wextra -Werror reconstructed.cpp -o verifier && ./verifier
   ```
3. **Compare Against Original Binary**:
   If possible, execute a harness calling both the original DLL/dylib (via `dlopen`/`LoadLibrary`) and the reconstructed source to verify 1:1 identical outputs.
