
#!/usr/bin/env bash
set -euo pipefail

# Check the tools required by the RISC-V Log Analyzer.

echo "=== RISC-V Environment Setup ==="

required_tools=(bash grep awk sed sort git make date realpath)
missing=0

for tool in "${required_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK] $tool"
    else
        echo "[MISSING] $tool"
        missing=$((missing + 1))
    fi
done

if (( missing > 0 )); then
    echo "Setup failed: $missing required tool(s) missing." >&2
    exit 1
fi

mkdir -p output

echo "Environment setup successful!"