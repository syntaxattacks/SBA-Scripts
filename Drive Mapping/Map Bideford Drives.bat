''Connect RSM P Drive
''Written by Dave Hann on 6-26-2015
NET USE I: /DELETE /YES
NET USE J: /DELETE /YES
net use I: \\sbasite.com\Users\Biddeford-ME\%USERNAME% /p:Yes
net use J: \\sbasite.com\Data\Biddeford-ME /p:Yes
if exist I:\ (
    if exist J:\ (
    del C:\Users\%USERNAME%\Desktop\"Map Biddeford Drives.bat"
)
)
