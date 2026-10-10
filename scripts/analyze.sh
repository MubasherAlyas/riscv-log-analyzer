
#!/bin/bash

# RISC-V Log Analyzer
# Reads simulation logs and counts test results.

set -euo pipefail

# Function 1: Display usage instructions
show_help() {
    echo "Usage: $0 <log_file>"
    echo "Example: $0 test_data/sample_pass.log"
}

# Check whether the user supplied a log file
if [[ $# -eq 0 ]]; then
    echo "Error: Missing log file argument." >&2
    show_help
    exit 2
fi

LOG_FILE="$1"

# Check whether the log file exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: File not found: $LOG_FILE" >&2
    exit 2
fi

# Function 2: Count PASS, FAIL, and SKIP results
analyze_log() {
    PASS_COUNT=$(grep -c 'TEST PASS:' "$LOG_FILE" || true)
    FAIL_COUNT=$(grep -c 'TEST FAIL:' "$LOG_FILE" || true)
    SKIP_COUNT=$(grep -c 'TEST SKIP:' "$LOG_FILE" || true)

    TOTAL=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
    
    # Calculate percentages safely
    if (( TOTAL > 0 )); then
        PASS_RATE=$(awk -v p="$PASS_COUNT" -v t="$TOTAL" 'BEGIN {printf "%.1f", (p/t)*100}')
        FAIL_RATE=$(awk -v f="$FAIL_COUNT" -v t="$TOTAL" 'BEGIN {printf "%.1f", (f/t)*100}')
        SKIP_RATE=$(awk -v s="$SKIP_COUNT" -v t="$TOTAL" 'BEGIN {printf "%.1f", (s/t)*100}')
    else
        PASS_RATE="0.0"
        FAIL_RATE="0.0"
        SKIP_RATE="0.0"
    fi

    echo "=== RISC-V Simulation Log Analysis ==="
    echo "Log file: $LOG_FILE"
    echo "Total tests: $TOTAL"
    
    echo "Passed: $PASS_COUNT ($PASS_RATE%)"
    echo "Failed: $FAIL_COUNT ($FAIL_RATE%)"
    echo "Skipped: $SKIP_COUNT ($SKIP_RATE%)"

    # Display the names of failed tests
    echo "--- Failed Tests ---"

    if (( FAIL_COUNT > 0 )); then
        grep 'TEST FAIL:' "$LOG_FILE" |
            sed -E 's/.*TEST FAIL: ([^ ]+).*/\1/' |
            awk '{print NR ". " $0}'
    else
        echo "None"
    fi
}

analyze_log

# Return failure when any test fails
if (( FAIL_COUNT > 0 )); then
    exit 1
fi

exit 0