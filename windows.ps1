#New-Item -Path C:\temp\thumbs -Force -ItemType Directory
#Invoke-WebRequest -Uri https://raw.githubusercontent.com/dataplat/dbatools/master/bin/dbatools-index.json -OutFile C:\temp\thumbs\index.json
$commands = Get-Content -Path "C:\github\dbatools\bin\dbatools-index.json" | ConvertFrom-Json
$commands = $commands | Where-Object CommandName -notin 'Write-Message','Set-DbatoolsConfig','Select-DbaObject'
#$commands = $commands | Select-Object -First 10
$commands = $commands | Where-Object Name -eq "Move-DbaDbFile"
$template = Get-Content -Path C:\github\actionstest\template.md
#rm C:\temp\thumbs\*.png

foreach ($command in $commands) {
    $name = $command.CommandName
    $author = $command.Author
    
    #write-warning $name
    $examples = $command.Examples.Split("`n") | Select-Object -First 3 -Skip 1
    $example = $examples | Where-Object { $PSItem -match $Name } | Select-Object -First 1
    if (-not $example) {
        $example = $command.Examples.Split("`n") | Select-Object -First 1 -Skip 1
    }
    $example = $example.Replace("PS C:\>", "")
    $example = $example.Replace("PS>", "")
    $example = $example.Replace("PS >", "")
    $example = $example.Replace("PS:\>", "")
    
    if ($example -match "@{") {
        $example = "# Check the docs! This is a long one."
    }

    $size = "57px"
    if ($name.Length -gt 29) {
        if ($name.Length -gt 34) {
            $size = "40px"
        } else {
            $size = "50px"
        }
    }

    if ($author.Length -gt 60) {
        $author = $author.Replace("|","<br/>")
    }
    $synopsis = $command.Synopsis
    $charCount = ($synopsis.ToCharArray() | Where-Object { $PSItem -eq '.' } | Measure-Object).Count

    if ($charCount -eq 1) {
        $synopsis = $synopsis.Replace(".","")
    }

    if ($name -eq "Start-DbaMigration") {
        $synopsis = $synopsis.Split("`n") | Select-Object -First 1
    }
    
    $content = $template.Replace("--COMMAND--", $name)
    $content = $content.Replace("--WORKSON--", $command.Availability)
    $content = $content.Replace("--SYNOPSIS--", $synopsis)
    $content = $content.Replace("--EXAMPLE--", $example)
    $content = $content.Replace("--AUTHOR--", $author)
    $content = $content.Replace("--SIZE--", $size)

    $content | Set-Content -Path C:\temp\thumbs\$name.md
    pandoc -f markdown -t html C:\temp\thumbs\$name.md -o C:\temp\thumbs\$name.html --self-contained --css=C:\github\actionstest\gh-pandoc.css
    npx playwright screenshot --viewport-size=1200,630 C:\temp\thumbs\$name.html C:\temp\thumbs\$name.png
    rm C:\temp\thumbs\*.html
    rm C:\temp\thumbs\*.md
}

 

foreach ($file in (Get-ChildItem C:\temp\thumbs\*.png)) {
    optipng -o7 $file
}

