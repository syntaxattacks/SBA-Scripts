''Connect N Drive
''Written by Dave Hann on 6-26-2015
NET USE N: /DELETE /YES
net use N: \\sbasite.com\data\WestboroughMA-Com /p:Yes
if exist N:\ (
    del C:\Users\%USERNAME%\Desktop\"Map N Drive.bat"
)
