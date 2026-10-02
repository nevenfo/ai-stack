# Remote Desktop Commander lean mode: reduce output noise only for RDC-spawned shells.
try {
    $selfProcess = Get-CimInstance Win32_Process -Filter "ProcessId=$PID" -ErrorAction Stop
    $parentProcess = Get-CimInstance Win32_Process -Filter "ProcessId=$($selfProcess.ParentProcessId)" -ErrorAction Stop
    if ($parentProcess.Name -ieq 'node.exe' -and $parentProcess.CommandLine -match '@wonderwhy-er[\\/]desktop-commander') {
        $env:PYTHONIOENCODING = 'utf-8'
        $env:NO_COLOR = '1'
        $PSStyle.OutputRendering = 'PlainText'
    }
} catch {
    # Keep the normal PowerShell environment unchanged if parent detection fails.
}

# RTK Automatic Wrappers for PowerShell
function git { rtk git $args }
function rg { rtk rg $args }
function npm { rtk npm $args }
function npx { rtk npx $args }
function pnpm { rtk pnpm $args }
function pip { rtk pip $args }
function uv { rtk uv $args }
function gh { rtk gh $args }
function dotnet { rtk dotnet $args }
function cargo { rtk cargo $args }
function pytest { rtk pytest $args }

# Bounded, non-recursive project detection for the single daily Codex entrypoint.
function Test-IsKiCadProject {
    param(
        [string]$Path = (Get-Location).Path,
        [int]$MaxParentLevels = 4
    )

    try {
        $directory = [System.IO.DirectoryInfo]::new([System.IO.Path]::GetFullPath($Path))
        $userRoot = [System.IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\')
    } catch {
        return $false
    }

    for ($level = 0; $directory -and $level -le $MaxParentLevels; $level++) {
        if ($directory.FullName.TrimEnd('\') -ieq $userRoot) {
            break
        }

        try {
            $matches = [System.IO.Directory]::EnumerateFiles(
                $directory.FullName,
                '*.kicad_pro',
                [System.IO.SearchOption]::TopDirectoryOnly
            ).GetEnumerator()
            if ($matches.MoveNext()) {
                return $true
            }
        } catch {
            # An inaccessible parent is not a KiCad signal.
        }

        $directory = $directory.Parent
    }

    return $false
}

# Single daily Codex entrypoint: lean by default, KiCad workaround when detected.
function codex {
    $profile = if (Test-IsKiCadProject) { 'cli-kicad' } else { 'cli-lean' }
    $codexPwsh = 'C:\Program Files\PowerShell\7\pwsh.exe'
    if ((Get-Process -Id $PID).Path -ieq $codexPwsh) {
        & "$env:APPDATA\npm\codex.cmd" --profile $profile --dangerously-bypass-approvals-and-sandbox @args
    } else {
        $command = '& "$env:APPDATA\npm\codex.cmd" --profile ' + $profile + ' --dangerously-bypass-approvals-and-sandbox @args'
        & $codexPwsh -NoProfile -CommandWithArgs $command @args
    }
}
