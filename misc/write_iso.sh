# This is for a mac
# From https://www.freecodecamp.org/news/how-make-a-windows-10-usb-using-your-mac-build-a-bootable-iso-from-your-macs-terminal/
diskutil list
diskutil eraseDisk MS-DOS "WIN10" GPT /dev/disk2
rsync -vha --exclude=sources/install.wim /Volumes/CCCOMA_X64FRE_EN-US_DV9/ /Volumes/WIN10
brew install wimlib
wimlib-imagex split /Volumes/CCCOMA_X64FRE_EN-US_DV9/sources/install.wim /Volumes/WIN10/sources/install.swm 4000

# diskutil unmountDisk /dev/diskN
# hdiutil convert -format UDRW -o /path/to/target.img /path/to/source.iso
# sudo dd if=/path/to/downloaded.img of=/dev/rdiskN bs=1m