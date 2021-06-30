function Get-TwitterMention ($Id) {
    $params = @{
        ExpansionType = 'Tweet'
        Endpoint      = "https://api.twitter.com/2/users/$Id/mentions"
        Query         = @{
            'max_results' = 20
        }
    }
    Invoke-TwitterRequest -RequestParameters $params
}

function Get-TwitterUser ($Id, $Username) {
    if (-not $script:users) {
        $script:users = @()
    }
    if ($Id) {
        $result = $script:users | Where-Object Id -eq $Id
        if ($result) {
            return $result
        }
        $params = @{
            ExpansionType = 'User'
            Endpoint      = "https://api.twitter.com/2/users/$Id"
        }
    }
    if ($Username) {
        $Username = $Username.Replace("@","")

        $result = $script:users | Where-Object Username -eq $Username
        if ($result) {
            return $result
        }
        $params = @{
            ExpansionType = 'User'
            Endpoint      = "https://api.twitter.com/2/users/by/username/$Username"
        }
    }

    Invoke-TwitterRequest -RequestParameters $params -OutVariable user
    $null = $script:users += $user
}

function Get-TwitterBlockedUserList ($Id) {
    return
    $params = @{
        ExpansionType = 'User'
        Endpoint      = "https://api.twitter.com/2/users/$Id/blocking"
        Query         = @{
            'max_results' = 49
        }
    }
    Invoke-TwitterRequest -RequestParameters $params
}

$bannedwords = @(
    't3ar',
    't3@r',
    'tear',
    'die',
    'tore',
    'blocked',
    'te@r',
    't3ar$',
    'classy',
    'Clippers',
    'Kings',
    'Bulls',
    'knicks',
    'Jazz',
    'Warrior',
    'Celtics',
    'Titan',
    'Curry',
    'Tide',
    'KingJames',
    'ratio',
    'NBA',
    'Derrick Rose',
    'Ja Morant',
    'Bears',
    'Kobe',
    'Vince Carter',
    'Yao Ming',
    'Kings',
    'DubNation',
    'Bron',
    'Bucks',
    'Raptors',
    'Ravens',
    'Duvernay',
    'Bills',
    'Buffalo',
    'truetoatlanta',
    'NFL',
    'Rams',
    'Suns',
    'Pats',
    'bolts',
    'Dolphin',
    'BrooklynTogether',
    'Pacer',
    'lakers',
    'seahawks',
    'seattlestorm',
    'trailblazers',
    'Knicks',
    'Jordan Clarkson',
    'Honest',
    'Stefon Diggs'
    'hooper',
    'heat',
    'd1e',
    'm@g@',
    'Westbrook',
    'Luka',
    '76',
    'Pistons',
    'oil prices',
    'price of oil',
    '\(\+',
    '\(\-'
)
$allowedwords = @(
    'dbatools',
    '-Dba',
    'SQL',
    'PowerShell',
    'book',
    'presentation',
    'Microsoft',
    'GitHub',
    'podcast'
)

$myid = 2993481
$mentions = Get-TwitterMention -Id $myid
$processed = @()
foreach ($mention in $mentions) {
    $entities = $mention.Entities.UserName | Where-Object { $PSItem -ne 'cl' } | Sort-Object 
    $mentionusername = (Get-TwitterUser -Id $mention.AuthorId).UserName
    if ($mentionusername -in $processed) {
        Write-Output "$mentionusername has already been processed"
        continue
    } else {
        $processed += $mentionusername
    }
    # Check if it's a directed tweet
    if ($mention.Entities.Count -eq 1 -and -not $mention.ReferencedTweets) {
        Write-Output "Skipping tweet from $($mentionusername) -- seems like a directed tweet"
        continue
    }

    $author = Get-TwitterUser -Id $mention.AuthorId
    $anyfollows = Get-TwitterFriendship -SourceUserName cl -TargetUserName $author.UserName 
 
    if ($anyfollows.Source -match "Blocking") {
        Write-Output "Skipping tweet from $($author.UserName) because they are already blocked"
        continue
    }
    if ($anyfollows.Source -match 'Following' -or $anyfollows.Target -match 'Following') {
        Write-Output "Skipping $($author.UserName) cuz y'all friends"
        continue
    }
    if ($anyfollows.Source -match 'none' -and $anyfollows.Target -match 'none') {
        Write-Output "No follow for $($author.UserName), processing"
        # Not following, not followed
        if ($mention.Text -match ($bannedwords -join "|") -and $mention.Text -notmatch ($allowedwords -join "|")) {
            #no API for muting conversation
            $author | Set-TwitterBlockedUser -Block
            Write-Output "BLOCKING $($author.UserName) FOR TWEET WORDS MATCHED"
            Write-Output $mention.Text
            continue
        }
        
        try {
            $twprofile = Get-TwitterUser -UserName $author.UserName
        } catch {
            Write-Output "$($author.UserName) no longer exists"
        }
        
        if ($twprofile.Description -match ($bannedwords -join "|")) {
            #no API for muting conversation
            $author | Set-TwitterBlockedUser -Block
            Write-Output "BLOCKING $($author.UserName) FOR PROFILE WORDS MATCHED"
            Write-Output $twprofile.Description
            continue
        }

        # if anyone else on the thread is blocked
        foreach ($entity in $entities) {
            $related = $entity.Replace("@","")
            if ($related -eq $author.Username) {
                Write-Output "Not a real entity"
                continue
            }

            if ($related -in $processed) {
                Write-Output "$related has already been processed"
                continue
            } else {
                $processed += $related
            }

            try {
                $anyfollows = Get-TwitterFriendship -SourceUserName cl -TargetUserName $related
            } catch {
                Write-Output "$related no longer exists"
                continue
            }
            if ($anyfollows.Source -match 'Following' -or $anyfollows.Target -match 'Following') {
                Write-Output "Skipping $related cuz y'all friends"
                continue
            }

            if ($anyfollows.Source -match "Blocking") {
                try {
                    $twuser = Get-TwitterUser -UserName $entity
                } catch {
                    Write-Output "$entity no longer exists"
                    continue
                }
                
                Write-Output "BLOCKING $($author.UserName) FOR RELATED BLOCKS $($twuser.UserName)"
                $author | Set-TwitterBlockedUser -Block
                continue
            }
        }
    }
    Write-Output "$($author.userName) made it past filters"
}
