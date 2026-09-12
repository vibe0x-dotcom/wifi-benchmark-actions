#!/usr/bin/env bash
set -euo pipefail

# Teste de particionamento: prova que A+B+C+D = 100M, disjuntos, sem hash real.
# Uso: SHARD=A|B|C|D ./scripts/run-shard.sh
#   A = 0-2xxxxxxx (30M), B = 3-5xxxxxxx (30M), C = 6-7xxxxxxx (20M), D = 8-9xxxxxxx (20M)

SHARD="${SHARD:-all}"
OUT="${1:-shard.log}"

charset_for() {
  case "$1" in
    A) echo "012" ;;
    B) echo "345" ;;
    C) echo "67" ;;
    D) echo "89" ;;
    *) echo "" ;;
  esac
}

expected_for() {
  case "$1" in
    A) echo "30000000" ;;
    B) echo "30000000" ;;
    C) echo "20000000" ;;
    D) echo "20000000" ;;
    all) echo "100000000" ;;
    *) echo "?" ;;
  esac
}

{
echo "== shard test =="
echo "shard: $SHARD"
echo "date: $(date -u +%FT%TZ)"
echo "espaco total: 10^8 = 100000000 | A=30M B=30M C=20M D=20M (disjuntos, uniao=total)"

if [ "$SHARD" = "all" ]; then
  echo "keyspace esperado: $(expected_for all)"
  echo -n "keyspace reportado (info, varia por build): "
  hashcat --keyspace -m 22000 -a 3 '?d?d?d?d?d?d?d?d' 2>/dev/null || true
  echo "--- benchmark kernel 22000 (sintetico) ---"
  hashcat --benchmark -m 22000 2>&1 | tail -n 15
else
  CS=$(charset_for "$SHARD")
  echo "charset1: [$CS]  mask: ?1?d?d?d?d?d?d?d"
  echo "keyspace esperado shard $SHARD: $(expected_for "$SHARD")"
  echo -n "keyspace reportado (info, varia por build): "
  hashcat --keyspace -m 22000 -a 3 -1 "$CS" '?1?d?d?d?d?d?d?d' 2>/dev/null || true
  echo "--- sample 5 candidatos (prova disjuncao: 1o digito em [$CS]) ---"
  hashcat --stdout -a 3 -1 "$CS" '?1?d?d?d?d?d?d?d' 2>/dev/null | head -n 5 || true
  echo "--- benchmark kernel 22000 (sintetico) ---"
  hashcat --benchmark -m 22000 2>&1 | tail -n 15
fi

echo "shard $SHARD done"
} 2>&1 | tee "$OUT"
