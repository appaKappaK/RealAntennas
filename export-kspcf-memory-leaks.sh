#!/usr/bin/env bash
set -euo pipefail

log_file="${1:-KSP.log}"
raw_output="${2:-KSPCF-memory-leaks-raw.txt}"
summary_output="${3:-KSPCF-memory-leaks-summary.txt}"
pattern='\[KSPCF:MemoryLeaks\] Removed a .* callback owned by a destroyed'

if [[ ! -f "$log_file" ]]; then
    echo "Log file not found: $log_file" >&2
    exit 1
fi

rg "$pattern" "$log_file" > "$raw_output" || true

sed -E 's/^.*Removed a ([^ ]+) callback owned by a destroyed ([^ ]+) instance.*$/\2 | \1/' "$raw_output" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -40 > "$summary_output"

matches=$(wc -l < "$raw_output")
echo "Found $matches matching leak callbacks"
echo "Wrote $raw_output"
echo "Wrote $summary_output"
