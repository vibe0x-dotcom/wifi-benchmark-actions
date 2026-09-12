#!/usr/bin/env bash
set -euo pipefail

# Coleta benchmark.log -> results/result.txt + results/benchmark.log
# Lógica "achou/não achou" simulada via linha Speed, sem credencial real.

IN="${1:-benchmark.log}"

mkdir -p results

cp "$IN" results/ 2>/dev/null || echo "(sem $IN)" > results/benchmark.log

if grep -q -E '^Speed' results/benchmark.log 2>/dev/null || grep -q -E 'Speed\.#1' results/benchmark.log 2>/dev/null; then
    grep -E 'Speed|Hash-Mode|Hash-Target|Time\.' results/benchmark.log > results/result.txt || true
    echo "RESULT: benchmark válido (sintético)." | tee -a results/result.txt
else
    echo "Nenhum resultado." > results/result.txt
fi

cat results/result.txt
