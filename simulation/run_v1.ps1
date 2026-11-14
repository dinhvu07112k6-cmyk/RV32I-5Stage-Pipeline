param([string]$IcarusBin = "$env:LOCALAPPDATA/Programs/IcarusVerilog/bin")
$ErrorActionPreference = 'Stop'
# Icarus emits UTF-8; Windows PowerShell otherwise decodes using the OEM code page.
$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8
$repoRoot = Split-Path $PSScriptRoot -Parent
Push-Location $repoRoot
try {
    $compiler = Join-Path $IcarusBin 'iverilog.exe'
    $runtime = Join-Path $IcarusBin 'vvp.exe'
    if (!(Test-Path $compiler)) { throw "Khong tim thay Icarus: $compiler. Truyen -IcarusBin de chon thu muc bin." }
    $rtl = @(Get-ChildItem rtl/*.v | ForEach-Object { "rtl/$($_.Name)" })
    $tests = @(Get-ChildItem tb/verification/*_full.v)
    $tests += Get-Item tb/integration/tb_cpu_top.v
    foreach ($test in $tests) {
        $top = $test.BaseName
        $out = "simulation/$top.out"
        $log = "simulation/$top.log"
        $testPath = Resolve-Path -LiteralPath $test.FullName -Relative
        & $compiler -g2012 -s $top -o $out @rtl $testPath
        if ($LASTEXITCODE -ne 0) { throw "Compile FAIL: $top" }
        $result = @(& $runtime $out 2>&1)
        $runExit = $LASTEXITCODE
        $result | Set-Content -Encoding UTF8 $log
        $result | Write-Output
        # Existing module benches use $finish on failures; inspect their counters too.
        $joined = $result -join "`n"
        if ($runExit -ne 0 -or $joined -match '(?im)^\s*\[?FAIL\]?' -or
            $joined -match '(?im)(FAIL(?:ED)?|THAT BAI)\s*[:=]\s*[1-9]' -or
            $joined -match '(?i)\b[1-9][0-9]*\s+FAILED\b') {
            throw "Simulation FAIL: $top (xem $log)"
        }
    }
} finally { Pop-Location }



