mpm --admin --install=tex4ht
mpm --admin --install=miktex-tex4ht
mpm --admin --install=miktex-tex4ht-bin-2.9

rem fix this part; it should auto-detect MikTeX paths instead.
rem 32bit/64bit detection; taken from https://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os (by Sam Spade)
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

if %OS%==32BIT echo "C:\Program Files\MikTex 2.9\scripts\tex4ht\htlatex.bat" "%%~n1" "xhtml,pic-m" > LaTeX_to_html.bat
if %OS%==64BIT echo "C:\Program Files (x86)\MikTex 2.9\scripts\tex4ht\htlatex.bat" "%%~n1" "xhtml,pic-m" > LaTeX_to_html.bat

copy LaTeX_to_html.bat "%USERPROFILE%\SendTo"
del LaTeX_to_html.bat

