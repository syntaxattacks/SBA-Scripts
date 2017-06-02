''Connect RSM P Drive
''Written by Dave Hann on 6-26-2015
NET USE P: /DELETE /YES
net use P: \\sbasite.com\app\RSMDocuments /p:Yes
if exist P:\ (
    del C:\Users\%USERNAME%\Desktop\"Map P Drive.bat"
)
