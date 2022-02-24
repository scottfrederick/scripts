#!/bin/bash

# from https://askubuntu.com/questions/1029562/move-snap-packages-to-another-location-directory

##############################################################################
# Take Care this section may break your System !!!
##############################################################################
##Move snap folder to Home instead of root.
#Create the directory : you can change the location
sudo mkdir -p /home/snap/snapd
sudo chown -R $USER:$USER /home/snap

#Stop auto-updating (will *not* crash snaps already open)
sudo systemctl mask snapd.service
sudo systemctl stop snapd.service
sudo systemctl disable snapd.service

#Copy the data
sudo rsync -avzP /var/lib/snapd/  /home/snap/snapd/

#Do backups
sudo mv /var/lib/snapd /var/lib/snapd.bak
sudo cp /etc/fstab /etc/fstab.bak

#Change fstab (Change $USER with your name or change the path totally)
echo "/home/snap/snapd /var/lib/snapd none bind 0 0" | sudo tee -a /etc/fstab

#remount fstab Or reboot.
sudo mkdir /var/lib/snapd
sudo mount -a
if ls /var/lib/snapd/ | grep snaps
then
    echo "Re-mounting snapd folder is done successfully. !!!!"
    sudo rm -rf /var/lib/snapd.bak
else
    echo "WARNING : Re-mounting snapd folder failed, please revert !!!!! "
    echo "WARNING : Re-mounting snapd folder failed, please revert !!!!! "
    echo "WARNING : Re-mounting snapd folder failed, please revert !!!!! "
    echo "WARNING : Re-mounting snapd folder failed, please revert !!!!! "
    echo "WARNING : Re-mounting snapd folder failed, please revert !!!!! "

    # Trying to revert automatically
    sudo cp /etc/fstab.bak /etc/fstab

    sudo mount -a
    sudo umount /var/lib/snapd

    sudo mv /var/lib/snapd.bak /var/lib/snapd

    echo "Files located at /home/snap/snapd should be removed, but are kept for
    recovery until you manually reboot the system and make sure the service
    is running correctly. Then you can manually remove the folder ~/snap/snapd
    !!!!!!!!!!!!!!, you should do that manually."

fi

#Restart auto-updating
sudo systemctl unmask snapd.service
sudo systemctl start snapd.service
sudo systemctl reenable snapd.service

##############################################################################
# Take care the previous section may break your System !!!
##############################################################################
