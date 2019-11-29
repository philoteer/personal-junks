:again
if "%~1" == "" goto done

md "%~p1/enc"

C:\ffmpeg\ffmpeg.exe -y -i "%~1" -threads 0 -sn -vcodec libx264 -preset slower -crf 25 -tune animation -sws_flags lanczos -acodec aac -strict experimental -ac 2 -ab 128k -r 23.98 "%~p1/enc/%~n1.mp4"

shift
goto again

:done
pause
