#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
MODE=${2:-prog}

if [ "$MODE" = system ]; then
    OUT=$RES/flame_${VARIANT}_system
    perf record -F 999 -a -g -o "$OUT.data" -- "$BIN" "$N" "$REPEATS"
    TITLE="System-wide CPU flame graph, bench_$VARIANT"
else
    OUT=$RES/flame_$VARIANT
    perf record -F 999 -g -o "$OUT.data" -- "$BIN" "$N" "$REPEATS"
    TITLE="CPU flame graph, bench_$VARIANT (N=$N, repeats=$REPEATS)"
fi

perf script -i "$OUT.data" > "$OUT.perf"
"$FG/stackcollapse-perf.pl" "$OUT.perf" > "$OUT.folded"
"$FG/flamegraph.pl" --title "$TITLE" "$OUT.folded" > "$OUT.svg"

echo "Готово: $OUT.svg"
echo "Топ функцій за кількістю семплів (власний час, верх стека):"
awk '{n=split($1,f,";"); c[f[n]]+=$2; t+=$2} END {for (k in c) printf "%6.2f%%  %s\n", 100*c[k]/t, k}' \
    "$OUT.folded" | sort -rn | head -8
