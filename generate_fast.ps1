param()
# January 2026 Commit Generator using git fast-import (raw byte stream)
$name = "Jamarius Fortson"
$email = "jamariusfortson.work@gmail.com"
$filename = "january_activity.txt"
$year = 2026
$month = 1
$daysInMonth = 31

$importPath = "$($PWD.Path)\git_import_raw.bin"
$stream = [System.IO.File]::Open($importPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
$enc = [System.Text.Encoding]::UTF8
$nl = [byte[]]@(10) # LF only

function WriteStr($s) {
    $b = $enc.GetBytes($s)
    $stream.Write($b, 0, $b.Length)
    $stream.Write($nl, 0, 1)
}

$fileContent = "Starting Activity for January 2026`n"

for ($day = 1; $day -le $daysInMonth; $day++) {
    $commitCount = Get-Random -Minimum 20 -Maximum 26
    Write-Host "Queuing $commitCount commits for January $day, 2026..."
    for ($i = 1; $i -le $commitCount; $i++) {
        $hour = Get-Random -Minimum 0  -Maximum 24
        $minute = Get-Random -Minimum 0  -Maximum 60
        $second = Get-Random -Minimum 0  -Maximum 60

        $dt = New-Object DateTime($year, $month, $day, $hour, $minute, $second, [System.DateTimeKind]::Utc)
        $unixTs = [int64]($dt - (New-Object DateTime(1970, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc))).TotalSeconds

        $fileContent += "Activity on $year-$month-$day ${hour}:${minute}:${second} - Commit $i`n"

        $contentBytes = $enc.GetBytes($fileContent)
        $msg = "Refactor and optimize code - Commit $i on Jan $day, 2026"
        $msgBytes = $enc.GetBytes($msg)

        WriteStr "commit refs/heads/main"
        WriteStr "committer $name <$email> $unixTs +0000"
        WriteStr "data $($msgBytes.Length)"
        WriteStr $msg
        WriteStr "M 644 inline $filename"
        WriteStr "data $($contentBytes.Length)"
        # write content bytes directly (no extra newline from WriteStr)
        $stream.Write($contentBytes, 0, $contentBytes.Length)
        $stream.Write($nl, 0, 1)
        WriteStr ""
    }
}

$stream.Flush()
$stream.Close()

Write-Host "Running git fast-import..."
$p = Start-Process -FilePath "git" -ArgumentList "fast-import", "--quiet" `
    -RedirectStandardInput $importPath `
    -RedirectStandardError ".\fast_import_err.txt" `
    -NoNewWindow -Wait -PassThru

if ($p.ExitCode -ne 0) {
    Write-Host "fast-import stderr:"
    Get-Content ".\fast_import_err.txt"
    exit 1
}

git reset --hard HEAD
$fileContent | Set-Content -Path $filename -NoNewline -Encoding utf8

Remove-Item $importPath -Force -ErrorAction SilentlyContinue
Remove-Item ".\fast_import_err.txt" -Force -ErrorAction SilentlyContinue

$count = (git rev-list --count HEAD)
Write-Host "Done! Total commits generated: $count"
