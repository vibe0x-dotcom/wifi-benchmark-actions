#!/usr/bin/env bash
set -euo pipefail

# Workload sintético: mede H/s sem nenhuma captura/credencial real.
# SHARD: A|B|C|D (opcional, só rotula o log para testar particionamento)
#   A = 0-2xxxxxxx (30M), B = 3-5xxxxxxx (30M), C = 6-7xxxxxxx (20M), D = 8-9xxxxxxx (20M)

SHARD="${SHARD:-all}"
OUT="${1:-benchmark.log}"

echo "== synthetic benchmark =="
echo "shard: $SHARD"
echo "date: $(date -u +%FT%TZ)"
clinfo 2>&1 | head -n 20 || true
echo "---"

# Benchmark real do kernel 22000 (sintético, sem hash file)
hashcat --benchmark -m 22000 2>&1 | tee "$OUT"

echo "---"
echo "shard $SHARD done" | tee -a "$OUT"
