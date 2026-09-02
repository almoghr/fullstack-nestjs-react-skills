# Decompilation Patterns & Idiom Recognition

This reference maps common compiler-generated assembly idioms back to high-level C/C++ source code constructs.

---

## 1. Pointer Null Check & Early Exit

### Assembly Pattern:
```assembly
test %rcx, %rcx
je   <error_or_return_label>
```
### Reconstructed C++:
```cpp
if (input == nullptr) {
    return nullptr; // or return false / error code
}
```

---

## 2. String Length & Null-Terminator Scan (`strlen` / loop)

### Assembly Pattern:
```assembly
loop_start:
    movzbl (%rcx), %eax
    test   %al, %al
    je     loop_end
    inc    %rcx
    jmp    loop_start
```
### Reconstructed C++:
```cpp
while (*p != '\0') {
    ++p;
}
```

---

## 3. Dynamic Heap Allocation (`malloc` / `operator new`)

### Assembly Pattern:
```assembly
lea    0x1(%rax), %rcx      # size + 1
call   malloc
test   %rax, %rax          # check allocation success
je     alloc_failed
mov    %rax, %rdi          # store destination pointer
```
### Reconstructed C++:
```cpp
char* buffer = static_cast<char*>(std::malloc(size + 1));
if (buffer == nullptr) {
    return nullptr;
}
```

---

## 4. C++ `std::string` Small String Optimization (SSO)

Compilers (GCC `libstdc++`, Clang `libc++`, MSVC) represent `std::string` with SSO:
- If string length $\le$ 15 bytes: characters are stored directly inside the stack object buffer (`[rsp + 0x10]`).
- If string length $>$ 15 bytes: a pointer to heap memory is stored at offset `0`, capacity at offset `0x10`, length at offset `0x8`.

### Identifying SSO Checks in Assembly:
```assembly
cmpq   $0xf, %rsi          # compare requested capacity with 15
ja     <heap_allocate>     # if > 15, allocate heap buffer
```

---

## 5. C++ Vector / Dynamic Array Traversal

`std::vector<T>` in memory layout consists of 3 pointers (24 bytes):
1. `begin_ptr` (offset 0)
2. `end_ptr` (offset 8)
3. `capacity_ptr` (offset 16)

### Assembly Loop Pattern:
```assembly
mov    0x0(%rbx), %rsi     # rsi = begin_ptr
mov    0x8(%rbx), %rdi     # rdi = end_ptr
cmp    %rdi, %rsi
je     vector_empty
loop:
    # process element at (%rsi)
    add    $sizeof(T), %rsi
    cmp    %rdi, %rsi
    jne    loop
```
### Reconstructed C++:
```cpp
for (const auto& item : vec) {
    // process item
}
```

---

## 6. Table / Character Set Membership

### Assembly Pattern:
```assembly
movzbl (%rsi), %eax       # read byte
bt     %rax, %r8          # bit-test against bitmap register
# or:
call   unordered_set::find
```
### Reconstructed C++:
```cpp
if (delimSet.count(ch) > 0) { ... }
```
