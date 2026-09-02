# Calling Conventions Reference for Binary Decompilation

When decompiling assembly to C/C++, correctly identifying function parameters and return values depends on the target architecture and operating system ABI.

---

## 1. Microsoft x64 Calling Convention (Windows PE DLL / EXE)

Windows 64-bit uses a single standard calling convention across all compilers (MSVC, MinGW, Clang):

| Argument Index | Integer / Pointer Register | Floating Point Register |
| :--- | :--- | :--- |
| **1st Argument** | `RCX` (`ECX`, `CX`, `CL`) | `XMM0` |
| **2nd Argument** | `RDX` (`EDX`, `DX`, `DL`) | `XMM1` |
| **3rd Argument** | `R8` (`R8D`, `R8W`, `R8B`) | `XMM2` |
| **4th Argument** | `R9` (`R9D`, `R9W`, `R9B`) | `XMM3` |
| **5th+ Arguments**| Pushed to stack (`[RSP + 0x28]`, `[RSP + 0x30]`, ...) | Stack |
| **Return Value** | `RAX` (`EAX`, `AX`, `AL`) | `XMM0` |

### Key Windows Characteristics
- **Shadow Space (Home Space)**: Callers MUST allocate 32 bytes (0x20) on the stack immediately before the `call`, even if fewer than 4 arguments are passed.
- **C++ `this` pointer**: Passed in `RCX` as the first argument for non-static member functions.

---

## 2. System V AMD64 ABI (Linux ELF & macOS Mach-O x86-64)

Used on Linux, macOS (Intel), and BSD:

| Argument Index | Integer / Pointer Register | Floating Point Register |
| :--- | :--- | :--- |
| **1st Argument** | `RDI` | `XMM0` |
| **2nd Argument** | `RSI` | `XMM1` |
| **3rd Argument** | `RDX` | `XMM2` |
| **4th Argument** | `RCX` | `XMM3` |
| **5th Argument** | `R8` | `XMM4` |
| **6th Argument** | `R9` | `XMM5` |
| **7th+ Arguments**| Stack | Stack |
| **Return Value** | `RAX` | `XMM0` |

---

## 3. ARM64 / AArch64 (macOS Apple Silicon & Linux AArch64)

Used on modern Macs (M1/M2/M3/M4) and ARM64 Linux:

| Argument Index | Register |
| :--- | :--- |
| **1st - 8th Arguments** | `X0` through `X7` (`W0` through `W7` for 32-bit values) |
| **Floating Point** | `D0` through `D7` / `V0` through `V7` |
| **9th+ Arguments** | Passed on the stack (`[SP]`, `[SP + 8]`, ...) |
| **Return Value** | `X0` (or `X0`-`X1` for 128-bit values / `D0` for float) |
| **Link Register** | `X30` (holds return address) |
| **Frame Pointer** | `X29` |
