#!/bin/bash

ARCH=`lscpu | grep Architecture:`
ACCARCH=("armv6h" "armv7h")
if [[ ${ACCARCH[*]} =~ ${ARCH##* } ]]
    then
        :
    else
        echo "You must be running an ARMv6 or ARMv7 system to use this script. If you believe you've received this message in error, please contact the developer."
        exit
fi

if [[ "$(id -u)" != "0" ]]
    then
        echo "This script must be executed with administrator privileges (sudo/root)."
        exit
fi


echo "#####################################"
echo "##     arkOS conversion script     ##"
echo "## (c) 2014 The CitizenWeb Project ##"
echo "#####################################"
echo ""
echo "This script will convert your Arch Linux system (running on an ARMv6 or ARMv7 device) to a full-featured arkOS distribution, with all accessory services."
echo ""
echo "This process is IRREVERSIBLE and results cannot be guaranteed. Please don't interrupt the conversion process!"
echo ""
echo "If you use a platform requiring a uboot flash, you should be asked during the process to do this. Make sure you respond properly or flash it manually before you attempt to reboot."
echo ""
echo "Enter YES in all caps if you want to proceed, enter NO or anything else to exit the script."
echo ""

while true; do
    read -p "Do you wish to proceed? " yn
    case $yn in
        [YES]* ) echo "Proceeding..."; break ;;
        * ) echo "Exiting."; exit;;
    esac
done

echo "STEP 1: Installing resource files"
wget -nv -O /etc/pacman.d/mirrorlist https://raw.githubusercontent.com/cznweb/arkos/master/PKGBUILDs/core/pacman-mirrorlist/mirrorlist || { echo "STEP 1 didn't complete successfully -- Failed to download/install resource files. Check your Internet connection before trying again."; exit 1; }
wget -nv -O /etc/pacman.conf https://raw.githubusercontent.com/cznweb/arkos/master/PKGBUILDs/core/pacman/pacman.conf || { echo "STEP 1 didn't complete successfully -- Failed to download/install resource files. Check your Internet connection before trying again."; exit 1; }
echo ""

echo "STEP 2: Installing packages and running updates"
pacman -Syu --force --noconfirm --noprogressbar nginx genesis beacon logrunner pacman pacman-mirrorlist python2-pillow python2-pip python2-psutil python2-iptables || { echo "STEP 2 didn't complete successfully -- pacman failed to install packages. Check your Internet connection before trying again."; exit 1; }
wget -nv -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/cznweb/arkos/master/scripts/nginx.conf || { echo "STEP 2 didn't complete successfully -- Failed to download/install resource files. Check your Internet connection before trying again."; exit 1; }
mkdir /etc/nginx/sites-available &> /dev/null
mkdir /etc/nginx/sites-enabled &> /dev/null
echo ""

echo "STEP 3: Enabling system services"
systemctl enable genesis
systemctl enable beacon
systemctl enable logrunner
echo ""

echo "STEP 4: Complete!"
echo ""

while true; do
    read -p "Your system needs to reboot [Y/n] " yn
    case $yn in
        [Nn]* ) echo "The installation process is complete! You'll need to reboot manually before changes come into effect."; exit ;;
        [Yy]* ) echo "Rebooting..."; reboot; exit;;
        * ) echo "I didn't understand that..."; ;;
    esac
done
