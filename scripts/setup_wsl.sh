#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq build-essential gdb time git valgrind \
    linux-tools-generic linux-tools-common

ln -sf "$(ls -d /usr/lib/linux-tools/*-generic | tail -1)/perf" /usr/local/bin/perf

[ -d /opt/FlameGraph ] || git clone --depth 1 https://github.com/brendangregg/FlameGraph /opt/FlameGraph

sysctl -q -w kernel.perf_event_paranoid=-1
sysctl -q -w kernel.kptr_restrict=0

perf --version
echo "OK: FlameGraph у /opt/FlameGraph"
