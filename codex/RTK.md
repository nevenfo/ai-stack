# RTK - Rust Token Killer (Codex CLI)

Use RTK for token-compressed shell output.

```powershell
rtk <executable> <args>  # git, rg, cargo, npm, pytest, etc.
rtk read <file>          # simple file read
rtk proxy pwsh -NoProfile -Command "<PowerShell>"  # cmdlet or pipeline
```

PowerShell cmdlets are not executables. Never call these directly through RTK:
`rtk Get-Content`, `rtk Test-Path`, `rtk Select-Object`, `rtk Set-Content`,
or `rtk New-Item`. Use `rtk proxy pwsh ...` instead.

Meta: `rtk gain`, `rtk gain --history`, `rtk --version`.
