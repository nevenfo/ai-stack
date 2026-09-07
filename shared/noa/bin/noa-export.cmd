@echo off
REM NOA KPI - stack-wide export into <repo>\exports\stack\ (timestamped).
REM
REM Not to be confused with export.ps1 at the repo root, which exports the
REM machine CONFIGURATION SNAPSHOT to Git. Two different things; the AGENTS.md
REM contract belongs to the latter.
REM
REM   noa-export.cmd            catch up, then stack export
REM   noa-export.cmd summary    aggregate on stdout
REM   noa-export.cmd cohorts    one aggregate per config version
REM   noa-export.cmd catchup    ingest native transcripts no hook ingested
REM
REM The bare form runs `catchup` first: a session-end hook does not always
REM fire - a newly added Codex hook stays disabled until the user approves it,
REM and a killed process fires nothing at all. Catch-up is idempotent, so the
REM export stays a pure read of metrics\events.jsonl either way. Its failure
REM must not cost the export, hence the ignored exit code.
setlocal
set "PYTHONPATH=%~dp0..\src"
set "PYTHONIOENCODING=utf-8:replace"
set "PYTHONUTF8=1"
if "%~1"=="" (
  python -m noa_kpi catchup
  python -m noa_kpi export
) else (
  python -m noa_kpi %*
)
exit /b %ERRORLEVEL%
