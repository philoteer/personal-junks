echo powershell -Command "(get-content %%1) -replace 'hfont', 'kotex' | Out-File -encoding utf8 \"%%~n1_kotex%%~x1\"" > hfont_to_kotex.bat

copy hfont_to_kotex.bat "%USERPROFILE%\SendTo"

set /p Input=Enter Yes or No:
