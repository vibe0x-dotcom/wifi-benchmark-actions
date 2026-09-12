#!/usr/bin/env bash
set -euo pipefail

# Wrapper: mantem compat, delega para run-shard.sh (particao A-D).
# Uso: SHARD=A|B|C|D ./scripts/run-benchmark.sh [saida.log]
exec "$(dirname "$0")/run-shard.sh" "${1:-benchmark.log}"
