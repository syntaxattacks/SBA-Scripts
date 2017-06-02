''Map Network Drive
''Written by Dave Hann on 7-6-2015

'' 1.)Fill in the Drive letter and the network location to map
'' 2.)Copy script to user's desktop
'' 3.)Have the user double click the icon. It will map the drives and remove itself from the computer 


net use [Drive] [Network Location] /p:yes
del C:\Users\%USERNAME%\Desktop\Map Network Drive.bat