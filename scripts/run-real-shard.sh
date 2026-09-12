#!/usr/bin/env bash
set -euo pipefail

SHARD="${SHARD:-A}"
HASHFILE="${HASHFILE:-hashes/purific-droso.hc22000}"
POTFILE="${POTFILE:-hashcat.potfile}"
OUT="${1:-shard.log}"

charset_for() {
  case "$1" in
    A) echo "012" ;;
    B) echo "345" ;;
    C) echo "67" ;;
    D) echo "89" ;;
    *)
      echo "Shard invalido: $1" >&2
      exit 1
      ;;
  esac
}

CS="$(charset_for "$SHARD")"
mkdir -p results

{
  echo "== shard $SHARD =="
  echo "date: $(date -u +%FT%TZ)"
  echo "hashfile: $HASHFILE"
  echo "charset1: [$CS] mask: ?1?d?d?d?d?d?d?d"

  echo "--- keyspace (info, varia por build) ---"
  hashcat --keyspace -m 22000 -a 3 -1 "$CS" '?1?d?d?d?d?d?d?d' || true

  echo "--- execucao ---"
  hashcat \
    -m 22000 \
    -a 3 \
    -1 "$CS" \
    "$HASHFILE" \
    '?1?d?d?d?d?d?d?d' \
    -O -w 3 --status \
    --potfile-path "$POTFILE" || true

  echo "--- resultados ---"
  hashcat \
    -m 22000 \
    "$HASHFILE" \
    --show \
    --potfile-path "$POTFILE" > results/show.txt || true

  if [ -s results/show.txt ]; then
    echo "FOUND"
    cat results/show.txt
  else
    echo "NOT FOUND"
  fi

  cp "$POTFILE" results/ 2>/dev/null || true
  echo "shard $SHARD done"

} 2>&1 | tee "$OUT"
