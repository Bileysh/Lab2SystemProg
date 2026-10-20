param(
    [ValidateSet('O0', 'O3')] [string]$Variant = 'O0',
    [int]$N = 1024,
    [int]$Repeats = 2,
    [int]$Runs = 1,
    [int]$IdleSec = 10,
    [string]$Distro = 'Ubuntu-24.04',
    [string]$WslDir = ''
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$res = Join-Path $root 'results'
New-Item -ItemType Directory -Force $res | Out-Null

$PWH_TO_J = 3.6e-9
function New-Rapl($inst) {
    New-Object System.Diagnostics.PerformanceCounter('Energy Meter', 'Energy', $inst, $true)
}
$pkg = New-Rapl 'rapl_package0_pkg'
$pp0 = New-Rapl 'rapl_package0_pp0'
function Read-Energy { [pscustomobject]@{ pkg = $pkg.RawValue; pp0 = $pp0.RawValue; t = [Diagnostics.Stopwatch]::GetTimestamp() } }
function Sec($a, $b) { ($b.t - $a.t) / [Diagnostics.Stopwatch]::Frequency }
function Joule($a, $b, $d) { ($b.$d - $a.$d) * $PWH_TO_J }
function Battery {
    try {
        $b = Get-CimInstance -Namespace root\wmi -ClassName BatteryStatus | Select-Object -First 1
        if ($b.Discharging) { $b.DischargeRate } else { $null }
    } catch { $null }
}

$wslRoot = if ($WslDir) { $WslDir } else { (wsl -d $Distro -u root --cd ~ -e wslpath -a ($root -replace '\\', '/')).Trim() }
$cmd = "cd '$wslRoot' && for i in `$(seq $Runs); do ./build/bench_$Variant $N $Repeats; done"

wsl -d $Distro -u root --cd ~ -e bash -c "cd '$wslRoot' && make -s all" | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Не вдалося зібрати програму у WSL ($wslRoot). Вкажіть -WslDir." }

Write-Host "Фон: $IdleSec с простою (не чіпайте ноутбук)..."
$i0 = Read-Energy; $batIdle = Battery
Start-Sleep -Seconds $IdleSec
$i1 = Read-Energy
$tIdle = Sec $i0 $i1
$pIdlePkg = (Joule $i0 $i1 'pkg') / $tIdle
$pIdlePp0 = (Joule $i0 $i1 'pp0') / $tIdle

Write-Host "Запуск bench_$Variant N=$N repeats=$Repeats x $Runs..."
$trace = New-Object System.Collections.Generic.List[string]
$trace.Add('t_s,pkg_W,pp0_W,battery_mW')
$p = Start-Process wsl -ArgumentList @('-d', $Distro, '-u', 'root', '--cd', '~', '-e', 'bash', '-c', "`"$cmd`"") `
    -NoNewWindow -PassThru -RedirectStandardOutput (Join-Path $res "energy_${Variant}_stdout.txt")
$null = $p.Handle
$r0 = Read-Energy; $prev = $r0; $batSamples = @()
while (-not $p.HasExited) {
    Start-Sleep -Milliseconds 100
    $cur = Read-Energy
    $dt = Sec $prev $cur
    if ($dt -gt 0) {
        $bat = Battery; if ($bat) { $batSamples += $bat }
        $trace.Add(('{0:F3},{1:F2},{2:F2},{3}' -f (Sec $r0 $cur), ((Joule $prev $cur 'pkg') / $dt), ((Joule $prev $cur 'pp0') / $dt), $bat))
    }
    $prev = $cur
}
$r1 = Read-Energy
if ($p.ExitCode -ne 0) { throw "bench_$Variant завершився з кодом $($p.ExitCode)" }
$t = Sec $r0 $r1
$ePkg = Joule $r0 $r1 'pkg'
$ePp0 = Joule $r0 $r1 'pp0'
$trace | Set-Content -Encoding ascii (Join-Path $res "energy_${Variant}_trace.csv")

$summary = [ordered]@{
    variant               = $Variant
    N                     = $N
    repeats               = $Repeats
    runs                  = $Runs
    time_s                = [math]::Round($t, 3)
    idle_pkg_W            = [math]::Round($pIdlePkg, 2)
    idle_cores_W          = [math]::Round($pIdlePp0, 2)
    avg_pkg_W             = [math]::Round($ePkg / $t, 2)
    avg_cores_W           = [math]::Round($ePp0 / $t, 2)
    system_pkg_J          = [math]::Round($ePkg, 2)
    program_pkg_J         = [math]::Round($ePkg - $pIdlePkg * $t, 2)
    program_cores_J       = [math]::Round($ePp0 - $pIdlePp0 * $t, 2)
    program_pkg_J_per_run = [math]::Round(($ePkg - $pIdlePkg * $t) / $Runs, 3)
}
if ($batSamples.Count -gt 0) {
    $avgBat = ($batSamples | Measure-Object -Average).Average / 1000
    $summary.battery_avg_W = [math]::Round($avgBat, 2)
    $summary.battery_system_J = [math]::Round($avgBat * $t, 2)
    if ($batIdle) { $summary.battery_idle_W = [math]::Round($batIdle / 1000, 2) }
} else {
    $summary.battery = 'на зарядці: DischargeRate недоступний (відключіть живлення для заміру всього ноутбука)'
}
$out = [pscustomobject]$summary
$out | Format-List
$out | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $res "energy_$Variant.json")
Write-Host "Трасa потужності: results\energy_${Variant}_trace.csv"
