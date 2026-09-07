@echo off
REM NOA Local Agent - read-only sub-task run by the local LLM.
REM
REM Doc: %USERPROFILE%\.claude\skills\noa-local-agents\SKILL.md
REM
REM This path is deliberately short and stable: it is the one allow-listed by
REM name in each harness. Moving it breaks those permissions.
REM
REM Comments here stay plain ASCII and carry no redirection characters:
REM cmd.exe parses redirections before REM, and mis-decodes accents under the
REM OEM code page - either one turns a comment into a failing command.
setlocal
set "PYTHONPATH=%~dp0..\src"
set "PYTHONIOENCODING=utf-8:replace"
set "PYTHONUTF8=1"
python -m noa_agents %*
exit /b %ERRORLEVEL%
