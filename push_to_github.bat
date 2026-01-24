@echo off
echo Pushing changes to GitHub...
"C:\Program Files\Git\cmd\git.exe" push -u origin main --force
if %errorlevel% neq 0 (
    echo.
    echo Er ging iets mis. Zie de melding hierboven.
) else (
    echo.
    echo Succes! De code staat op GitHub.
)
echo.
pause
