#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"

for v in O0 O3; do
    [ -f "$RES/flame_$v.folded" ] || { echo "Немає $RES/flame_$v.folded — запустіть 1_flamegraph.sh $v"; exit 1; }
done

sed 's/^bench_O0;/bench;/' "$RES/flame_O0.folded" > "$RES/_a.folded"
sed 's/^bench_O3;/bench;/' "$RES/flame_O3.folded" > "$RES/_b.folded"

"$FG/difffolded.pl" -n "$RES/_a.folded" "$RES/_b.folded" \
    | "$FG/flamegraph.pl" --title "Differential flame graph: O0 -> O3 (normalized)" \
    > "$RES/flame_diff_O0_O3.svg"
rm -f "$RES/_a.folded" "$RES/_b.folded"
echo "Готово: $RES/flame_diff_O0_O3.svg"
