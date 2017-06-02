''Map Network Drive
''Written by Dave Hann on 7-6-2015

'' 1.)Copy script to user's desktop
'' 2.)Fill in the Drive letter and the network location to map
'' 3.)Have the user double click the icon. It will map the drives and remove itself from the computer

net use T: /Delete
net use H: /Delete
net use O: /Delete

net use T: \\TN21FS01\common$ /p:Yes
net use H: \\sbasite.com\Data\Lewisville-TX /p:Yes
net use O: \\sbasite.com\Data /p:Yes
