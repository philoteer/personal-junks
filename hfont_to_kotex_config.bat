echo powershell -Command "(get-content %%1) -replace '(usepackage{.*)hfont', '$1kotex' | Out-File -encoding utf8 \"%%~n1_kotex%%~x1\"" > hfont_to_kotex.bat

copy hfont_to_kotex.bat "%USERPROFILE%\SendTo"
del hfont_to_kotex.bat
