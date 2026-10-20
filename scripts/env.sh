cd "$(dirname "${BASH_SOURCE[0]}")/.."

FG=${FG:-/opt/FlameGraph}
N=${N:-1024}
REPEATS=${REPEATS:-2}
RES=results
mkdir -p "$RES"

VARIANT=${1:-O0}
BIN=./build/bench_$VARIANT
[ -x "$BIN" ] || make -s all
