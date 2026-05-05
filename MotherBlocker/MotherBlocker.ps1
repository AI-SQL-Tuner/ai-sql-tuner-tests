# PowerShell example: launch 10 parallel calls with random overlapping ranges
$server = "RockyPC"
$db = "tpch10"
$ranges = @(
    @{From='1995-01-01'; To='1995-03-31'},
    @{From='1995-02-15'; To='1995-05-15'},
    @{From='1995-04-01'; To='1995-06-30'},
    @{From='1995-05-01'; To='1995-08-31'},
    @{From='1995-07-01'; To='1995-12-31'}
)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$jobs = 1..10 | ForEach-Object {
    $run = $_
    $r = $ranges | Get-Random
    Start-Job -Name "MB_$run" -ScriptBlock {
        param($runNumber, $s, $d, $f, $t)

        $query = "SET NOCOUNT ON; EXEC dbo.usp_UpdateOrdersAndLineitem @FromDate='$f', @ToDate='$t';"
        $output = sqlcmd -S $s -d $d -E -Q $query 2>&1
        $exitCode = $LASTEXITCODE

        [pscustomobject]@{
            Run      = $runNumber
            FromDate = $f
            ToDate   = $t
            ExitCode = $exitCode
            Output   = ($output | ForEach-Object { $_.ToString() })
        }
    } -ArgumentList $run, $server, $db, $r.From, $r.To
}

$null = Wait-Job -Job $jobs

foreach ($job in $jobs | Sort-Object Id) {
    $result = Receive-Job -Job $job
    if (-not $result) {
        Write-Host "[$($job.Name)] No output received." -ForegroundColor Yellow
        continue
    }

    Write-Host "`n================================================" -ForegroundColor Cyan
    Write-Host "[$($job.Name)] Run $($result.Run): $($result.FromDate) -> $($result.ToDate) | ExitCode: $($result.ExitCode)" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan

    if ($result.Output -and $result.Output.Count -gt 0) {
        $result.Output | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "(sqlcmd produced no output)"
    }
}

Remove-Job -Job $jobs -Force

$stopwatch.Stop()
Write-Host "`n================================================" -ForegroundColor Green
Write-Host "Total execution time: $($stopwatch.Elapsed.ToString('hh\:mm\:ss\.fff'))" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
