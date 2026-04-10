# January 2026 GitHub Commit Generator
# This script generates 20-25 commits for each day in January 2026

$year = 2026
$month = 1
$daysInMonth = 31

# Ensure git is initialized
if (-not (Test-Path .git)) {
    git init
    Write-Host "Initialized empty Git repository."
}

# Clear/create activity tracking file
$filename = "january_activity.txt"
"Starting Activity for January 2026" | Out-File -FilePath $filename -Encoding utf8
git add $filename

for ($day = 1; $day -le $daysInMonth; $day++) {
    $commitCount = Get-Random -Minimum 20 -Maximum 26 # 20 to 25 inclusive
    
    Write-Host "Generating $commitCount commits for January $day, 2026..."
    
    for ($i = 1; $i -le $commitCount; $i++) {
        # Generate a random hour (0-23), minute, and second for the commit
        $hour = Get-Random -Minimum 0 -Maximum 24
        $minute = Get-Random -Minimum 0 -Maximum 60
        $second = Get-Random -Minimum 0 -Maximum 60
        
        $dateString = "$year-$month-$day $($hour):$($minute):$($second)"
        $message = "Refactor and optimize code - Commit $i on Jan $day, 2026"
        
        # Append to file to create a change
        Add-Content -Path $filename -Value "Activity on $dateString - Commit $i"
        
        # Stage and commit with the backdated timestamp
        git add $filename
        $env:GIT_AUTHOR_DATE = $dateString
        $env:GIT_COMMITTER_DATE = $dateString
        git commit -m "$message" --quiet
    }
}

Write-Host "Successfully generated January 2026 commits."
