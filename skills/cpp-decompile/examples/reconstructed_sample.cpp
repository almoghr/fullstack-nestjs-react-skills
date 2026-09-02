/**
 * reconstructed_sample.cpp - Reference Reconstruction Example
 *
 * Demonstrates clean ABI export reconstruction, null safeguards,
 * memory lifetime management, and verification test harness.
 */

#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>
#include <cstring>

static const char* DEFAULT_DELIMITERS = "!@#$%^&*";

extern "C" {

/**
 * Exported: Checks for presence of delimiter characters.
 */
bool HasSpecialCharacters(const char* input, const char* delimiters) {
    if (!input) return false;
    const char* delim = (delimiters && *delimiters) ? delimiters : DEFAULT_DELIMITERS;
    return std::strpbrk(input, delim) != nullptr;
}

/**
 * Exported: Allocates buffer and returns doubled tokens.
 */
char* ProcessAndDoubleAlloc(const char* input, const char* delimiters) {
    if (!input || !HasSpecialCharacters(input, delimiters)) {
        return nullptr;
    }

    const char* delim = (delimiters && *delimiters) ? delimiters : DEFAULT_DELIMITERS;
    std::string src(input);
    std::string result;
    size_t start = 0;

    while (start < src.size()) {
        size_t end = src.find_first_of(delim, start);
        if (end == std::string::npos) end = src.size();

        if (end > start) {
            std::string word = src.substr(start, end - start);
            if (!result.empty()) result += " ";
            result += word + word; // Double word
        }
        start = end + 1;
    }

    char* buffer = static_cast<char*>(std::malloc(result.size() + 1));
    if (buffer) {
        std::memcpy(buffer, result.c_str(), result.size() + 1);
    }
    return buffer;
}

/**
 * Exported: Frees heap-allocated buffers returned by the library.
 */
void FreeBuffer(char* ptr) {
    if (ptr) {
        std::free(ptr);
    }
}

} // extern "C"

#ifdef BUILD_SAMPLE_TEST
int main() {
    const char* sample = "hello!world@test";
    if (HasSpecialCharacters(sample, nullptr)) {
        char* doubled = ProcessAndDoubleAlloc(sample, nullptr);
        std::cout << "Result: " << doubled << "\n";
        FreeBuffer(doubled);
    }
    return 0;
}
#endif
