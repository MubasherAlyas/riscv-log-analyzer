
#!/usr/bin/env bash
set -euo pipefail

# Generate individual reports for all sample simulation logs.

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANALYZER="$PROJECT_DIR/scripts/analyze.sh"
DATA_DIR="$PROJECT_DIR/test_data"
OUTPUT_DIR="$PROJECT_DIR/output"

mkdir -p "$OUTPUT_DIR"

echo "=== Generating RISC-V Reports ==="

for logfile in "$DATA_DIR"/*.log; do
    [[ -f "$logfile" ]] || continue

    filename="$(basename "$logfile" .log)"
    report="$OUTPUT_DIR/${filename}_report.txt"

    # Exit code 1 means the simulation contains failed tests.
    # Exit code 2 indicates an input or processing error.
    status=0
    "$ANALYZER" "$logfile" --output "$report" || status=$?

    if (( status > 1 )); then
        echo "Error processing $logfile" >&2
        exit "$status"
    fi

    echo "Generated: $report"
done

echo "Report generation completed."