#!/usr/bin/env bash
# ==============================================================================
# inspect_binary.sh - Inspect binary architecture, headers, exports & imports
# ==============================================================================
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <path-to-binary>"
    exit 1
fi

BINARY="$1"

if [ ! -f "$BINARY" ]; then
    echo "Error: File '$BINARY' does not exist."
    exit 1
fi

echo "======================================================================"
echo " 1. BINARY FILE IDENTIFICATION"
echo "======================================================================"
file "$BINARY"

echo ""
echo "======================================================================"
echo " 2. EXPORTED SYMBOLS / FUNCTIONS"
echo "======================================================================"

# Determine best tool for format
if file "$BINARY" | grep -qi "PE32"; then
    if command -v x86_64-w64-mingw32-objdump >/dev/null 2>&1; then
        echo "[Format: Windows PE] Export Table:"
        x86_64-w64-mingw32-objdump -p "$BINARY" | awk '/The Export Tables/,/The Function Table/' || true
    else
        objdump -p "$BINARY" 2>/dev/null || nm -gU "$BINARY" 2>/dev/null || true
    fi
elif file "$BINARY" | grep -qi "Mach-O"; then
    echo "[Format: Mach-O] Dynamic Symbols:"
    nm -gU "$BINARY" 2>/dev/null || true
elif file "$BINARY" | grep -qi "ELF"; then
    echo "[Format: ELF] Dynamic Symbols:"
    objdump -T "$BINARY" 2>/dev/null || nm -D "$BINARY" 2>/dev/null || true
else
    echo "Generic symbol listing:"
    nm -g "$BINARY" 2>/dev/null || true
fi

echo ""
echo "======================================================================"
echo " 3. IMPORTED LIBRARIES & SYSTEM CALLS"
echo "======================================================================"
if file "$BINARY" | grep -qi "PE32"; then
    if command -v x86_64-w64-mingw32-objdump >/dev/null 2>&1; then
        x86_64-w64-mingw32-objdump -p "$BINARY" | grep -A 5 "DLL Name:" || true
    fi
elif file "$BINARY" | grep -qi "Mach-O"; then
    otool -L "$BINARY" 2>/dev/null || true
fi

echo ""
echo "======================================================================"
echo " 4. EMBEDDED STRINGS (Length >= 4, first 30)"
echo "======================================================================"
strings "$BINARY" | grep -E '^[A-Za-z0-9_!@#$%^&*()+\-=/.,:; ]{4,}$' | head -n 30 || true
