#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RTL_FILES=(rtl/*.v)
TESTS=(tb/verification/*_full.v tb/integration/tb_cpu_top.v)

echo "=========================================================="
echo "        CHẠY TOÀN BỘ KIỂM THỬ CPU RV32I V1 (LINUX)       "
echo "=========================================================="

for test in "${TESTS[@]}"; do
    top=$(basename "$test" .v)
    out="simulation/$top.out"
    log="simulation/$top.log"

    printf "Running %-30s ... " "$top"
    iverilog -g2012 -s "$top" -o "$out" "${RTL_FILES[@]}" "$test"
    if [ $? -ne 0 ]; then
        echo "COMPILE FAIL"
        exit 1
    fi

    vvp "$out" > "$log" 2>&1
    runExit=$?

    if [ $runExit -ne 0 ] || grep -qiE "^\s*\[?FAIL\]?|(FAIL(ED)?|THAT BAI)\s*[:=]\s*[1-9]|\b[1-9][0-9]*\s+FAILED\b" "$log"; then
        echo "SIMULATION FAIL (xem $log)"
        exit 1
    fi
    echo "OK"
done

echo "=========================================================="
echo ">>> TOÀN BỘ 8 KIỂM THỬ MODULE VÀ CPU TOP ĐỀU PASS! <<<"
echo "=========================================================="

