
#!/usr/bin/env bash
set -euo pipefail

# RISC-V Simulation Log Analyzer
# Exit codes: 0 = no failed tests, 1 = failed tests, 2 = usage/input error.

show_help() {
    cat <<'HELP'
Usage: scripts/analyze.sh <log_file> [OPTIONS]

Options:
  --format text|csv    Output format (default: text)
  --output PATH        Save report to a file
  --verbose            Print processing information to stderr
  --help               Show this help message
HELP
}

error() {
    echo "Error: $*" >&2
    exit 2
}

FORMAT="text"
OUTPUT=""
VERBOSE=false
LOG_FILE=""

# Parse command-line arguments.
while (( $# > 0 )); do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --format)
            (( $# >= 2 )) || error "Missing format value"
            FORMAT="$2"
            shift 2
            ;;
        --output)
            (( $# >= 2 )) || error "Missing output path"
            OUTPUT="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -*)
            error "Unknown option: $1"
            ;;
        *)
            [[ -z "$LOG_FILE" ]] || error "Multiple log files supplied"
            LOG_FILE="$1"
            shift
            ;;
    esac
done

[[ -n "$LOG_FILE" ]] || error "Log file is required"
[[ -f "$LOG_FILE" && -r "$LOG_FILE" ]] || error "Cannot read $LOG_FILE"
[[ "$FORMAT" == "text" || "$FORMAT" == "csv" ]] ||
    error "Format must be text or csv"

# Prevent overwriting the input log.
if [[ -n "$OUTPUT" ]]; then
    [[ "$(realpath -m "$OUTPUT")" != "$(realpath "$LOG_FILE")" ]] ||
        error "Output cannot overwrite input log"
fi

$VERBOSE && echo "Processing: $LOG_FILE" >&2

# Parse completed test records and compute statistics.
analyze_log() {
    awk -v format="$FORMAT" -v logfile="$LOG_FILE" \
        -v analysis_date="$(date '+%Y-%m-%d %H:%M:%S')" '
    function pct(n) {
        return total ? 100 * n / total : 0
    }

    /TEST (PASS|FAIL|SKIP):/ {
        line = $0
        sub(/^.*TEST /, "", line)

        status = line
        sub(/:.*/, "", status)

        name = line
        sub(/^[^:]+:[[:space:]]*/, "", name)
        sub(/[[:space:]].*$/, "", name)

        total++
        names[total] = name
        statuses[total] = status

        if (status == "PASS") passed++
        else if (status == "FAIL") {
            failed++
            failures[failed] = name
        }
        else if (status == "SKIP") skipped++

        duration = ""
        if (match(line, /\([0-9]+(\.[0-9]+)?s\)/)) {
            duration = substr(line, RSTART + 1, RLENGTH - 3) + 0
            times[total] = duration
            sum += duration
            timed++

            if (timed == 1 || duration < min) {
                min = duration
                min_name = name
            }
            if (timed == 1 || duration > max) {
                max = duration
                max_name = name
            }
        }
    }

    END {
        verdict = failed > 0 ? "FAIL" : "PASS"

        if (format == "csv") {
            print "test_name,status,execution_time_seconds"
            for (i = 1; i <= total; i++) {
                if (i in times)
                    printf "%s,%s,%.2f\n", names[i], statuses[i], times[i]
                else
                    printf "%s,%s,\n", names[i], statuses[i]
            }
            printf "TOTAL,%d,\n", total
            printf "PASSED,%d,\n", passed
            printf "FAILED,%d,\n", failed
            printf "SKIPPED,%d,\n", skipped
            printf "PASS_RATE,%.1f%%,\n", pct(passed)
            printf "VERDICT,%s,\n", verdict
        } else {
            print "=== RISC-V Simulation Log Analysis ==="
            print "Log file: " logfile
            print "Analysis date: " analysis_date
            print "--- Results Summary ---"
            printf "Total tests: %d\n", total
            printf "Passed: %d (%.1f%%)\n", passed, pct(passed)
            printf "Failed: %d (%.1f%%)\n", failed, pct(failed)
            printf "Skipped: %d (%.1f%%)\n", skipped, pct(skipped)

            print "--- Failed Tests ---"
            if (failed == 0) print "None"
            for (i = 1; i <= failed; i++)
                printf "%d. %s\n", i, failures[i]

            print "--- Execution Times ---"
            for (i = 1; i <= total; i++)
                if (i in times)
                    printf "%s: %.2fs\n", names[i], times[i]

            print "--- Timing Statistics ---"
            if (timed) {
                printf "Min time: %.2fs (%s)\n", min, min_name
                printf "Max time: %.2fs (%s)\n", max, max_name
                printf "Avg time: %.2fs\n", sum / timed
            } else {
                print "No execution time data available"
            }

            print "--- Verdict: " verdict " ---"
        }
    }' "$LOG_FILE"
}

# Save the report or display it on stdout.
if [[ -n "$OUTPUT" ]]; then
    [[ -d "$(dirname "$OUTPUT")" ]] ||
        error "Output directory does not exist"
    analyze_log > "$OUTPUT" || error "Report generation failed"
    $VERBOSE && echo "Report saved: $OUTPUT" >&2
else
    analyze_log
fi

# A failure is a test result, not a parser error.
FAIL_COUNT=$(grep -c 'TEST FAIL:' "$LOG_FILE" || true)
if (( FAIL_COUNT > 0 )); then
    exit 1
fi
exit 0
