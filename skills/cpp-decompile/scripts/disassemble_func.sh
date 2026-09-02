#!/usr/bin/env bash
# ==============================================================================
# disassemble_func.sh - Extract disassembly for a specific symbol or function
# ==============================================================================
set -u

if [ $# -lt 2 ]; then
    echo "Usage: $0 <path-to-binary> <function-name-or-symbol>"
    exit 1
fi

BINARY="$1"
FUNC="$2"

if [ ! -f "$BINARY" ]; then
    echo "Error: Binary '$BINARY' does not exist."
    exit 1
fi

echo "Extracting disassembly for function '$FUNC' in '$BINARY'..."

OBJDUMP_BIN="objdump"
if file "$BINARY" | grep -qi "PE32"; then
    if command -v x86_64-w64-mingw32-objdump >/dev/null 2>&1; then
        OBJDUMP_BIN="x86_64-w64-mingw32-objdump"
    fi
fi

# Disassemble and extract function block safely
"$OBJDUMP_BIN" -d --no-show-raw-insn "$BINARY" 2>/dev/null | awk -v fn="$FUNC" '
    $0 ~ ("<.*" fn ".*>:") { printing=1; print; next }
    printing && /^$/ { printing=0; exit }
    printing { print }
' || true
