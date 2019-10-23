rem Requires Powershell 6

echo "C:\Program Files\PowerShell\6\pwsh.exe" -Command "(get-content %%~n1%%~x1) -replace '(usepackage{.*)hfont', '$1kotex' | Out-File -encoding UTF8NoBOM \"%%~n1_kotex%%~x1\"" > hfont_to_kotex.bat
rem echo powershell -Command "(get-content %%~n1%%~x1) -replace '(usepackage{.*)hfont', '$1kotex' | Out-File -encoding UTF8NoBOM \"%%~n1_kotex%%~x1\"" > hfont_to_kotex.bat

copy hfont_to_kotex.bat "%USERPROFILE%\SendTo"
del hfont_to_kotex.bat
