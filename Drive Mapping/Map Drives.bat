''Connect RSM P Drive
''Written by Dave Hann on 6-26-2015
NET USE h: /DELETE /YES
NET USE J: /DELETE /YES
NET USE K: /DELETE /YES
NET USE L: /DELETE /YES
NET USE S: /DELETE /YES
NET USE t: /DELETE /YES
NET USE h:	\\fl1fs1.sbasite.com\accounting$  /p:Yes
NET USE J:	\\fl1fs1.sbasite.com\data /p:Yes
NET USE K:	\\fl1fs1.sbasite.com\gplains$ /p:Yes
NET USE L:	\\fl1fs1.sbasite.com\sba_accounting$ /p:Yes
NET USE S:	\\fl1fs1.sbasite.com\aatlegal$ /p:Yes
NET USE T:	\\fl1fs1.sbasite.com\aataccounting$ /p:Yes
del C:\Users\%USERNAME%\Desktop\"Map Drives.bat"

