#!/bin/sh
# Reports the host binary's text/data/bss against the model's codeSize/dataSize/budgetedMemory
# (read from the pinned structure run). Report only: the budgets are the model's and are never resized.
host="$1"; run="$2"
[ -x "$host" ] && [ -f "$run" ] || { echo "usage: report_sizes.sh <argent_host> <runs/sw-fsw-structure.txt>" >&2; exit 1; }
budget() { awk -v key="$1" '$0 ~ key {getline; gsub(/[^0-9.]/, "", $0); printf "%.0f", $0; exit}' "$run"; }
code=$(budget 'software[.]codeSize'); data=$(budget 'software[.]dataSize'); mem=$(budget 'software[.]budgetedMemory')
set -- $(size "$host" | awk 'NR == 2 { print $1, $2, $3 }')
text="$1"; sdata="$2"; bss="$3"
file=$(wc -c < "$host")
echo "argent_host: file ${file} B, text ${text} B, data ${sdata} B, bss ${bss} B (host build, -O2)"
echo "model budgets: codeSize ${code} B, dataSize ${data} B, budgetedMemory ${mem} B"
awk -v t="$text" -v c="$code" -v d="$sdata" -v b="$bss" -v ds="$data" -v m="$mem" 'BEGIN {
  printf "text/codeSize = %.2f %%, (data+bss)/dataSize = %.2f %%, file/budgetedMemory = %.4f %%\n", 100*t/c, 100*(d+b)/ds, 100*(t+d+b)/m }'
