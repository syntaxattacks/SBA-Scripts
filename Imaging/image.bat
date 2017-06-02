D:
@echo off
diskpart /s D:\CreatePartitions-UEFI.txt

ECHO "Applying OS Image"
dism /apply-image /imagefile:D:\install.wim /index:1 /ApplyDir:W:\

bcdedit /set {bootmgr} device partition=s:
bcdedit /set {memdiag} device partition=s:
bcdedit /set {default} device partition=w:
bcdedit /set {default} osdevice partition=w:
Bcdedit /set {FWbootmgr} displayorder {Bootmgr} /addfirst

W:\Windows\System32\bcdboot W:\Windows /s S:

W:\Windows\system32\shutdown /r /t 0