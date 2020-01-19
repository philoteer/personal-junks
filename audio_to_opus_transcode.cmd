:again
if "%~1" == "" goto done

md "%~p1/enc"

C:\ffmpeg\ffmpeg.exe -i "%~1" -c:a libopus -b:a 96K "%~p1/enc/%~n1.opus"

C:\ffmpeg\ffmpeg.exe -i "%~1" -c:v copy "%~p1/enc/%~n1.jpeg"

if exist "%~p1/enc/%~n1.jpeg" (
"C:\Program Files\MKVToolNix\mkvmerge.exe" -o "%~p1/enc/%~n1.mka"   "%~p1/enc/%~n1.opus"  --attach-file "%~p1/enc/%~n1.jpeg"
) else (
"C:\Program Files\MKVToolNix\mkvmerge.exe" -o "%~p1/enc/%~n1.mka"   "%~p1/enc/%~n1.opus"
)


shift
goto again

:done
pause