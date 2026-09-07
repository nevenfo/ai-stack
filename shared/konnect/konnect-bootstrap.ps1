param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$KonnectArguments = @()
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0
$script:ForwardedArguments = @($KonnectArguments)

$script:Repository = "nevenfo/kicad-agentic-mcp"
$script:ApiUrl = "https://api.github.com/repos/$($script:Repository)/releases?per_page=30"
$script:DownloadPrefix = "https://github.com/$($script:Repository)/releases/download/"
$script:DefaultCheckInterval = [TimeSpan]::FromHours(1)

function Write-KonnectDiagnostic {
    param([string]$Message)
    [Console]::Error.WriteLine("[konnect-bootstrap] $Message")
}

function ConvertTo-KonnectVersion {
    param([Parameter(Mandatory = $true)][string]$Value)
    if ($Value -notmatch '(?i)(?:^|\s)v?(\d+)\.(\d+)\.(\d+)(?:\s|$)') {
        return $null
    }
    return "$([int]$Matches[1]).$([int]$Matches[2]).$([int]$Matches[3])"
}

function Compare-KonnectVersion {
    param(
        [Parameter(Mandatory = $true)][string]$Left,
        [Parameter(Mandatory = $true)][string]$Right
    )
    $leftParts = $Left.Split('.')
    $rightParts = $Right.Split('.')
    for ($index = 0; $index -lt 3; $index++) {
        $comparison = ([int]$leftParts[$index]).CompareTo([int]$rightParts[$index])
        if ($comparison -ne 0) { return $comparison }
    }
    return 0
}

function Get-InstalledKonnectVersion {
    param([Parameter(Mandatory = $true)][string]$BinaryPath)
    if (-not (Test-Path -LiteralPath $BinaryPath -PathType Leaf)) { return $null }
    try {
        $versionOutput = @(& $BinaryPath --version 2>$null)
        if ($LASTEXITCODE -ne 0 -or $versionOutput.Count -eq 0) { return $null }
        return ConvertTo-KonnectVersion ([string]$versionOutput[0])
    } catch {
        return $null
    }
}

function Get-GitHubStableReleases {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $headers = @{
        Accept = "application/vnd.github+json"
        "User-Agent" = "FlowUP-Konnect-Bootstrap/1"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    return @(Invoke-RestMethod -Uri $script:ApiUrl -Headers $headers -Method Get -TimeoutSec 8)
}

function Select-LatestStableRelease {
    param([Parameter(Mandatory = $true)]$Releases)
    $eligible = @($Releases | Where-Object {
        -not [bool]$_.draft -and -not [bool]$_.prerelease -and
        ([string]$_.tag_name -match '^v?\d+\.\d+\.\d+$') -and $_.published_at
    } | Sort-Object { [DateTimeOffset]::Parse([string]$_.published_at) } -Descending)
    if ($eligible.Count -eq 0) { return $null }
    return $eligible[0]
}

function Get-WindowsPcmAsset {
    param(
        [Parameter(Mandatory = $true)]$Release,
        [Parameter(Mandatory = $true)][string]$Version
    )
    $expectedName = "konnect-pcm-v$Version-windows.zip"
    $assets = @($Release.assets | Where-Object { [string]$_.name -ceq $expectedName })
    if ($assets.Count -ne 1) { throw "release must contain exactly one $expectedName asset" }
    $asset = $assets[0]
    $url = [string]$asset.browser_download_url
    if (-not $url.StartsWith($script:DownloadPrefix, [StringComparison]::Ordinal)) {
        throw "asset URL is not owned by the official repository"
    }
    if ([long]$asset.size -le 0 -or [long]$asset.size -gt 300MB) {
        throw "asset size is invalid"
    }
    $digest = [string]$asset.digest
    if ($digest -and $digest -notmatch '^sha256:[0-9a-fA-F]{64}$') {
        throw "unsupported asset digest"
    }
    return $asset
}

function Copy-GitHubAsset {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Destination
    )
    Add-Type -AssemblyName System.Net.Http
    $handler = New-Object Net.Http.HttpClientHandler
    $client = New-Object Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromSeconds(20)
    $client.DefaultRequestHeaders.UserAgent.ParseAdd("FlowUP-Konnect-Bootstrap/1")
    try {
        $response = $client.GetAsync($Url, [Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
        try {
            $response.EnsureSuccessStatusCode() | Out-Null
            $inputStream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
            try {
                $outputStream = New-Object IO.FileStream($Destination, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
                try { $inputStream.CopyTo($outputStream) } finally { $outputStream.Dispose() }
            } finally { $inputStream.Dispose() }
        } finally { $response.Dispose() }
    } finally {
        $client.Dispose()
        $handler.Dispose()
    }
}

function Test-KonnectAssetIntegrity {
    param(
        [Parameter(Mandatory = $true)][string]$ArchivePath,
        [Parameter(Mandatory = $true)]$Asset
    )
    $file = Get-Item -LiteralPath $ArchivePath
    if ($file.Length -ne [long]$Asset.size) { throw "downloaded asset size mismatch" }
    $digest = [string]$Asset.digest
    if ($digest) {
        $expected = $digest.Substring(7).ToLowerInvariant()
        $actual = (Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -cne $expected) { throw "downloaded asset SHA-256 mismatch" }
    }
}

function Expand-KonnectPcmPayload {
    param(
        [Parameter(Mandatory = $true)][string]$ArchivePath,
        [Parameter(Mandatory = $true)][string]$Destination
    )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $required = @(
        "__init__.py",
        "plugin.json",
        "settings_dialog.py",
        "bin/konnect.exe",
        "bin/schematic-viewer.exe",
        "resources/icon.png"
    )
    $seen = @{}
    $archive = [IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        foreach ($entry in $archive.Entries) {
            $name = $entry.FullName.Replace('\', '/')
            if (-not $name.StartsWith("plugins/", [StringComparison]::Ordinal)) { continue }
            $relative = $name.Substring(8)
            if (-not $relative -or $relative.EndsWith('/')) { continue }
            if ($relative.StartsWith('/') -or $relative.Contains(':') -or $relative.Split('/') -contains '..') {
                throw "unsafe PCM archive entry"
            }
            $key = $relative.ToLowerInvariant()
            if ($seen.ContainsKey($key)) { throw "duplicate PCM archive entry" }
            $seen[$key] = $true
            $target = Join-Path $Destination ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            $targetDirectory = Split-Path -Parent $target
            $null = New-Item -ItemType Directory -Path $targetDirectory -Force
            $sourceStream = $entry.Open()
            try {
                $targetStream = New-Object IO.FileStream($target, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
                try { $sourceStream.CopyTo($targetStream) } finally { $targetStream.Dispose() }
            } finally { $sourceStream.Dispose() }
        }
    } finally { $archive.Dispose() }
    foreach ($relative in $required) {
        if (-not (Test-Path -LiteralPath (Join-Path $Destination $relative) -PathType Leaf)) {
            throw "PCM archive is missing $relative"
        }
    }
    $manifest = Get-Content -LiteralPath (Join-Path $Destination "plugin.json") -Raw | ConvertFrom-Json
    if ([string]$manifest.identifier -cne "com.github.mixelpixx.konnect") {
        throw "unexpected PCM plugin identifier"
    }
    $entrypoints = @($manifest.actions | ForEach-Object { [string]$_.entrypoint })
    if ($entrypoints -notcontains "bin/konnect.exe") { throw "unexpected PCM executable entrypoint" }
}

function Read-KonnectCache {
    param([Parameter(Mandatory = $true)][string]$CachePath)
    try { return Get-Content -LiteralPath $CachePath -Raw | ConvertFrom-Json } catch { return $null }
}

function Test-KonnectCacheCurrent {
    param(
        $Cache,
        [Parameter(Mandatory = $true)][string]$LocalVersion,
        [Parameter(Mandatory = $true)][TimeSpan]$CheckInterval
    )
    if (-not $Cache) { return $false }
    try {
        return ([string]$Cache.latest_version -ceq $LocalVersion) -and
            (([DateTimeOffset]::UtcNow - [DateTimeOffset]::Parse([string]$Cache.checked_utc)) -lt $CheckInterval)
    } catch {
        return $false
    }
}

function Write-KonnectCache {
    param(
        [Parameter(Mandatory = $true)][string]$CachePath,
        [Parameter(Mandatory = $true)][string]$LatestVersion
    )
    $directory = Split-Path -Parent $CachePath
    $null = New-Item -ItemType Directory -Path $directory -Force
    $temporary = "$CachePath.$([Guid]::NewGuid().ToString('N')).tmp"
    @{ checked_utc = [DateTimeOffset]::UtcNow.ToString('o'); latest_version = $LatestVersion } |
        ConvertTo-Json | Set-Content -LiteralPath $temporary -Encoding UTF8
    Move-Item -LiteralPath $temporary -Destination $CachePath -Force
}

function Install-KonnectPcmRelease {
    param(
        [Parameter(Mandatory = $true)][string]$PluginRoot,
        [Parameter(Mandatory = $true)][string]$StateRoot,
        [Parameter(Mandatory = $true)][string]$Version,
        [Parameter(Mandatory = $true)]$Asset,
        [Parameter(Mandatory = $true)][scriptblock]$AssetFetcher
    )
    $null = New-Item -ItemType Directory -Path $StateRoot -Force
    $archivePath = Join-Path $StateRoot ("download-" + [Guid]::NewGuid().ToString('N') + ".zip")
    $stagePath = Join-Path (Split-Path -Parent $PluginRoot) (".konnect-update-" + [Guid]::NewGuid().ToString('N'))
    $backupPath = Join-Path (Join-Path $StateRoot "rollback") ("v" + ((Get-InstalledKonnectVersion (Join-Path $PluginRoot "bin/konnect.exe")) -replace '[^0-9.]', '') + "-" + [DateTime]::UtcNow.ToString('yyyyMMddHHmmss') + "-" + [Guid]::NewGuid().ToString('N'))
    try {
        & $AssetFetcher ([string]$Asset.browser_download_url) $archivePath
        Test-KonnectAssetIntegrity $archivePath $Asset
        $null = New-Item -ItemType Directory -Path $stagePath -Force
        Expand-KonnectPcmPayload $archivePath $stagePath
        $stagedVersion = Get-InstalledKonnectVersion (Join-Path $stagePath "bin/konnect.exe")
        if (-not $stagedVersion -or (Compare-KonnectVersion $stagedVersion $Version) -ne 0) {
            throw "staged executable version mismatch"
        }
        $null = New-Item -ItemType Directory -Path (Split-Path -Parent $backupPath) -Force
        Move-Item -LiteralPath $PluginRoot -Destination $backupPath
        try {
            Move-Item -LiteralPath $stagePath -Destination $PluginRoot
        } catch {
            Move-Item -LiteralPath $backupPath -Destination $PluginRoot
            throw
        }
        return [pscustomobject]@{ Updated = $true; Version = $Version; BackupPath = $backupPath }
    } finally {
        if (Test-Path -LiteralPath $archivePath) { Remove-Item -LiteralPath $archivePath -Force }
        if (Test-Path -LiteralPath $stagePath) { Remove-Item -LiteralPath $stagePath -Recurse -Force }
    }
}

function Invoke-KonnectBootstrap {
    param(
        [Parameter(Mandatory = $true)][string]$PluginRoot,
        [Parameter(Mandatory = $true)][string]$StateRoot,
        [scriptblock]$ReleaseFetcher = { Get-GitHubStableReleases },
        [scriptblock]$AssetFetcher = { param($Url, $Destination) Copy-GitHubAsset $Url $Destination },
        [TimeSpan]$CheckInterval = $script:DefaultCheckInterval,
        [switch]$ForceCheck
    )
    $binaryPath = Join-Path $PluginRoot "bin/konnect.exe"
    $localVersion = Get-InstalledKonnectVersion $binaryPath
    $cachePath = Join-Path $StateRoot "release-cache.json"
    $cache = Read-KonnectCache $cachePath
    if (-not $ForceCheck -and $localVersion -and (Test-KonnectCacheCurrent $cache $localVersion $CheckInterval)) {
        return [pscustomobject]@{ Updated = $false; Version = $localVersion; BinaryPath = $binaryPath; Source = "cache" }
    }
    try {
        $release = Select-LatestStableRelease (& $ReleaseFetcher)
        if (-not $release) { throw "GitHub returned no stable published release" }
        $latestVersion = ConvertTo-KonnectVersion ([string]$release.tag_name)
        if (-not $latestVersion) { throw "GitHub returned an invalid stable tag" }
        Write-KonnectCache $cachePath $latestVersion
        if ($localVersion -and (Compare-KonnectVersion $localVersion $latestVersion) -ge 0) {
            return [pscustomobject]@{ Updated = $false; Version = $localVersion; BinaryPath = $binaryPath; Source = "github" }
        }
        $asset = Get-WindowsPcmAsset $release $latestVersion
        $installed = Install-KonnectPcmRelease $PluginRoot $StateRoot $latestVersion $asset $AssetFetcher
        Write-KonnectDiagnostic "updated Konnect $localVersion -> $latestVersion; rollback=$($installed.BackupPath)"
        return [pscustomobject]@{ Updated = $true; Version = $latestVersion; BinaryPath = $binaryPath; Source = "github"; BackupPath = $installed.BackupPath }
    } catch {
        if (Test-Path -LiteralPath $binaryPath -PathType Leaf) {
            Write-KonnectDiagnostic "update check/install failed; using local Konnect ($($_.Exception.Message))"
            return [pscustomobject]@{ Updated = $false; Version = $localVersion; BinaryPath = $binaryPath; Source = "fallback" }
        }
        throw
    }
}

function Invoke-LiveKonnectBootstrap {
    $pluginRoot = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "KiCad\10.0\3rdparty\plugins\com_github_mixelpixx_konnect"
    $stateRoot = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) "konnect-bootstrap"
    $mutex = New-Object Threading.Mutex($false, "Local\FlowUP.KonnectBootstrap.Update")
    $locked = $false
    try {
        try { $locked = $mutex.WaitOne([TimeSpan]::FromSeconds(30)) } catch [Threading.AbandonedMutexException] { $locked = $true }
        if ($locked) {
            $result = Invoke-KonnectBootstrap -PluginRoot $pluginRoot -StateRoot $stateRoot
        } else {
            Write-KonnectDiagnostic "update lock timeout; using local Konnect"
            $result = [pscustomobject]@{ BinaryPath = (Join-Path $pluginRoot "bin/konnect.exe") }
        }
    } finally {
        if ($locked) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
    if (-not (Test-Path -LiteralPath $result.BinaryPath -PathType Leaf)) {
        throw "no local Konnect executable is available"
    }
    return [string]$result.BinaryPath
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        $liveBinaryPath = Invoke-LiveKonnectBootstrap
        & $liveBinaryPath @script:ForwardedArguments
        exit $LASTEXITCODE
    } catch {
        Write-KonnectDiagnostic $_.Exception.Message
        exit 1
    }
}
