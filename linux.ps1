#New-Item -Path /mnt/c/temp/thumbs -Force -ItemType Directory
Invoke-WebRequest -Uri https://raw.githubusercontent.com/dataplat/dbatools/master/bin/dbatools-index.json -OutFile /mnt/c/temp/thumbs/index.json
$commands = Get-Content -Path /mnt/c/temp/thumbs/index.json | ConvertFrom-Json | Where-Object Name -notin 'Write-Message','Set-DbatoolsConfig','Select-DbaObject'
$commands = $commands | Select-Object -First 10
$template = Get-Content -Path /mnt/c/github/actionstest/template.md

foreach ($command in $commands) {
    $name = $command.CommandName
    $example = $command.Examples.Split("`n") | Select-Object -First 1 -Skip 1
    $example = $example.Replace("PS C:\>", "")
    $example = $example.Replace("PS>", "")
    if ($example.Length -gt 120) {
        #$example = $example.Substring(0, 120) + "..."
    }
    $content = $template.Replace("--COMMAND--", $name)
    $content = $content.Replace("--WORKSON--", $command.Availability)
    $content = $content.Replace("--SYNOPSIS--", $command.Synopsis)
    $content = $content.Replace("--EXAMPLE--", $example)
    $content = $content.Replace("--AUTHOR--", $command.Author)

    $content | Set-Content -Path /mnt/c/temp/thumbs/$name.md
    pandoc -f markdown -t html /mnt/c/temp/thumbs/$name.md -o /mnt/c/temp/thumbs/$name.html --self-contained --css=/mnt/c/github/actionstest/gh-pandoc.css
    npx playwright screenshot --viewport-size=1200,630 /mnt/c/temp/thumbs/$name.html /mnt/c/temp/thumbs/$name.png
    optipng -o7 /mnt/c/temp/thumbs/$name.png | Out-Null
}

rm /mnt/c/temp/thumbs/*.html
rm /mnt/c/temp/thumbs/*.md



