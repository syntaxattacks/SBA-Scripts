''Map Network Drive
''Written by Dave Hann on 7-6-2015

'' 1.)Copy script to user's desktop
'' 2.)Fill in the Drive letter and the network location to map
'' 3.)Have the user double click the icon. It will map the drives and remove itself from the computer

net use H: /Delete
net use H: \\fl1fs1\pm$ /p:Yes
del C:\Users\%USERNAME%\Desktop\"Map H Drive.bat"
