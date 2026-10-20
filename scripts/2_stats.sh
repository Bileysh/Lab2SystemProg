#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
P=$RES/${VARIANT}

echo "=== 2.1 /usr/bin/time --verbose ==="
/usr/bin/time --verbose "$BIN" "$N" "$REPEATS" 2>&1 | tee "${P}_time.txt"

echo; echo "=== 2.2 perf stat -d (5 повторів, середнє ± розкид) ==="
perf stat -d -r 5 -o "${P}_perfstat.txt" -- "$BIN" "$N" "$REPEATS" > /dev/null
cat "${P}_perfstat.txt"

if command -v valgrind > /dev/null; then
    echo; echo "=== 2.2b valgrind --tool=cachegrind (N=256, 1 прохід) ==="
    valgrind --tool=cachegrind --cache-sim=yes --cachegrind-out-file="${P}_cachegrind.out" \
        "$BIN" 256 1 2>&1 | grep -E '^==[0-9]+== (I|D|LL|Branches|Mispred)' | tee "${P}_cachegrind.txt"
fi

echo; echo "=== 2.3 perf record + perf report ==="
perf record -F 999 -g -o "${P}_perf.data" -- "$BIN" "$N" "$REPEATS" > /dev/null
perf report -i "${P}_perf.data" --stdio --no-children --sort symbol,dso 2> /dev/null \
    | grep -v '^$' | head -40 | tee "${P}_report.txt"
perf report -i "${P}_perf.data" --stdio --children --sort symbol -g none 2> /dev/null \
    | grep -v '^$' | head -25 | tee "${P}_report_children.txt"
perf annotate -i "${P}_perf.data" --stdio -s matmul 2> /dev/null \
    | head -80 > "${P}_annotate_matmul.txt"
echo "Анотація matmul: ${P}_annotate_matmul.txt"
