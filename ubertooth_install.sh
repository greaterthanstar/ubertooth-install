#!/bin/bash

#
# Ubertooth install script for Kali Linux 2.0.0
#
# by Raul Siles
# Copyright (c) 2015 DinoSec SL (www.dinosec.com)
#
# Version: 2017-03-R2
# Date: 2015-10-31
#
# Ubertooth and libbtbb versions: 2017-03-R2
# Kali Linux version: 2.0.0
# Wireshark version: 1.12.6
# Kismet version: 2013-03-R1b
#

# Versions
VERSION=2017-03-R2
KALI_VERSION=2.0.0
UBER_VERSION=2017-03-R2
WIRESHARK_VERSION=1.12.6
KISMET_VERSION=2016-07-R1

LIBBTBB_URL=https://github.com/greatscottgadgets/libbtbb/archive/$UBER_VERSION.tar.gz
LIBBTBB_FILENAME=libbtbb-$UBER_VERSION.tar.gz
LIBBTBB_DIR=libbtbb-$UBER_VERSION
LIBBTBB_BACK=../..

UBERTOOTH_URL=https://github.com/greatscottgadgets/ubertooth/releases/download/$UBER_VERSION/ubertooth-$UBER_VERSION.tar.xz
UBERTOOTH_FILENAME=ubertooth-$UBER_VERSION.tar.xz
UBERTOOTH_DIR_HOST=ubertooth-$UBER_VERSION/host
UBERTOOTH_DIR=ubertooth-$UBER_VERSION
UBERTOOTH_BACK=../../..

KISMET_URL=https://kismetwireless.net/code/kismet-$KISMET_VERSION.tar.xz
KISMET_FILENAME=kismet-$KISMET_VERSION.tar.xz
KISMET_DIR=kismet-$KISMET_VERSION
KISMET_CONF_FILE=/usr/local/etc/kismet.conf
KISMET_BACK=..

WIRESHARK_PLUGINS_DIR=/usr/lib/x86_64-linux-gnu/wireshark/plugins/$WIRESHARK_VERSION

# ASCII Art:
# http://patorjk.com/software/taag/
# Based on figlet

echo
echo "  _   _ _               _              _   _       _____          _        _ _ "
echo " | | | | |             | |            | | | |     |_   _|        | |      | | |"
echo " | | | | |__   ___ _ __| |_ ___   ___ | |_| |__     | | _ __  ___| |_ __ _| | |"
echo " | | | |  _ \ / _ \ ^__| __/ _ \ / _ \| __|  _ \    | || ^_ \/ __| __/ _^ | | |"
echo " | |_| | |_) |  __/ |  | || (_) | (_) | |_| | | |  _| || | | \__ \ || (_| | | |"
echo "  \___/|_.__/ \___|_|   \__\___/ \___/ \__|_| |_|  \___/_| |_|___/\__\__,_|_|_|"
echo

echo
echo " - Script to install Ubertooth $UBER_VERSION in Kali Linux $KALI_VERSION -"
echo
echo "   Version: $VERSION"
echo "   By Raul Siles (DinoSec - www.dinosec.com)"
echo
echo "   Tools Versions:"
echo "   - Ubertooth & libbtbb: $UBER_VERSION"
echo "   - Kali Linux: $KALI_VERSION"
echo "   - Wireshark: $WIRESHARK_VERSION"
echo "   - Kismet: $KISMET_VERSION"
echo

echo "  (*** Internet access is required ***)"
echo "  (*** This script will run for a few minutes. Be patient... ***)"
echo
echo "  Press any key to continue (or Ctrl+C):"
read key

echo "[*] Installing Ubertooth dependencies..."
echo
sudo apt-get install git cmake libusb-1.0-0-dev make gcc g++ libbluetooth-dev \
pkg-config libpcap-dev python-numpy python-pyside python-qt4

echo
echo "[*] Building the Bluetooth baseband library (libbtbb)..."
wget $LIBBTBB_URL -O $LIBBTBB_FILENAME
tar xf $LIBBTBB_FILENAME
cd $LIBBTBB_DIR
mkdir build
cd build
cmake ..
make
sudo make install
cd $LIBBTBB_BACK

echo
echo "[*] Installing Ubertooth tools..."
echo
wget $UBERTOOTH_URL -O $UBERTOOTH_FILENAME
tar xf $UBERTOOTH_FILENAME
cd $UBERTOOTH_DIR_HOST
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig
cd $UBERTOOTH_BACK

echo
echo "[*] Building Kismet and the Ubertooth Kismet plugin..."
echo
sudo apt-get -y install libpcap0.8-dev libcap-dev pkg-config build-essential libnl-3-dev libnl-genl-3-dev libncurses5-dev libpcre3-dev libpcap-dev libcap-dev
wget $KISMET_URL
tar xf $KISMET_FILENAME
cd $KISMET_DIR
ln -s ../$UBERTOOTH_DIR/host/kismet/plugin-ubertooth .
./configure
make dep && make && make plugins
sudo make suidinstall
sudo make plugins-install
cd $KISMET_BACK

echo
echo "[*] Adding 'pcapbtbb' to the 'logtypes=...' line in kismet.conf..."
#
# Kali Linux 2.0.0
# /etc/kismet/kismet.conf <-- Not used
# /usr/local/etc/kismet.conf <-- Used when manually compiled
#
sudo cp $KISMET_CONF_FILE $KISMET_CONF_FILE.previous
sed -i 's/\(pcapdump,gpsxml,netxml,nettxt,alert,string\)/\1,pcapbtbb/g' $KISMET_CONF_FILE
#OR:
#sed -i 's/logtypes=pcapdump/logtypes=pcapbtbb,pcpadump/g' $KISMET_CONF_FILE
#

# echo
# echo "[*] Building the Ubertooth BTBB Wireshark plugin..."
# echo
# sudo apt-get -y install wireshark wireshark-dev libwireshark-dev cmake
# cd $LIBBTBB_DIR/wireshark/plugins/btbb
# mkdir build
# cd build
# cmake -DCMAKE_INSTALL_LIBDIR=$WIRESHARK_PLUGINS_DIR ..
# make
# sudo make install
# cd ../../../../..

# echo
# echo "[*] Building the Ubertooth BT BR/EDR Wireshark plugin..."
# echo
# sudo apt-get -y install wireshark wireshark-dev libwireshark-dev cmake
# cd $LIBBTBB_DIR/wireshark/plugins/btbredr
# mkdir build
# cd build
# cmake -DCMAKE_INSTALL_LIBDIR=$WIRESHARK_PLUGINS_DIR ..
# make
# sudo make install
# cd ../../../../..


echo
echo "[*] End of the Ubertooth install script. Congratulations! ;)"
echo

