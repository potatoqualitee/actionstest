$params = @{
    ApiKey            = $env:TAPIKEY
    ApiSecret         = $env:TAPIKEYSECRET
    AccessToken       = $env:TACCESSTOKEN
    AccessTokenSecret = $env:TACCESSTOKENSECRET
}
#Set-TwitterAuthentication @params
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
    'm@g@'
)
# ONCE DONE, LOOK TO PROFILE FOR BANNED WORDS
$allowedwords = @(
    'dbatools',
    '-Dba',
    'SQL',
    'PowerShell',
    'book',
    'presentation',
    'Microsoft',
    'GitHub'
)

$Id = 2993481
$mentions = Get-TwitterMention -Id $Id
$entities = $mentions.Entities.UserName | Where-Object { $PSItem -ne 'cl' } | Sort-Object -Unique
$processed = @()
foreach ($mention in $mentions) {
    $mentionusername = (Get-TwitterUser -Id $mention.AuthorId).UserName
    if ($mentionusername -in $processed) {
        continue
    } else {
        $processed += $mentionusername
    }
    # Check if it's a directed tweet
    if ($mention.Entities.Count -eq 1 -and -not $mention.ReferencedTweets) {
        Write-Output "Skipping tweet from $($mentionusername)"
        continue
    }

    $author = Get-TwitterUser -Id $mention.AuthorId
    $anyfollows = Get-TwitterFriendship -SourceUserName cl -TargetUserName $author.UserName  
    
    if ($anyfollows.Source -match 'none' -and $anyfollows.Target -match 'none') {
        Write-Output "No follow for $($author.UserName)"
        # Not following, not followed
        if ($mention.Text -match ($bannedwords -join "|") -and $mention.Text -notmatch ($allowedwords -join "|")) {
            #no API for muting conversation
            Set-TwitterBlockedUser -User $author.UserName -Block
            Write-Warning "BLOCKING $($author.UserName) FOR TWEET WORDS MATCHED"
            Write-Warning $mention.Text
            continue
        }
        
        try {
            $twprofile = Get-TwitterUser -UserName $author.UserName
        } catch {}
        
        if ($twprofile.Description -match ($bannedwords -join "|")) {
            #no API for muting conversation
            Set-TwitterBlockedUser -User $author.UserName -Block
            Write-Warning "BLOCKING $($author.UserName) FOR PROFILE WORDS MATCHED"
            Write-Warning $twprofile.Description
            continue
        }
        # if anyone else on the thread is blocked
        foreach ($entity in $entities) {
            $anyfollows = Get-TwitterFriendship -SourceUserName cl -TargetUserName $entity.Replace("@","")
    
            if ($anyfollows.Source -match 'none' -and $anyfollows.Target -match 'none') {
                try {
                    $id = (Get-TwitterUser -UserName $entity).Id
                } catch {}
                if ($id -in $blocked.Id) {
                    Write-Warning "BLOCKING $(author.UserName) FOR RELATED BLOCKS ($id)"
                    Set-TwitterBlockedUser -User $entity -Block
                    continue
                }
            }
        }
    }
}