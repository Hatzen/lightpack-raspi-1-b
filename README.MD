# Setup to install Prismatik on Raspberry 1 B 
This is a guide how i set up my old lightpack and raspberry pi 1 B for Remote control (no screen grabbing)

NOTE: (Running this currently lead to "error" response on setcolor api call, setstatus works properly see https://github.com/woodenshark/Lightpack/issues/69)

1. Install raspios buster via Imager.
2. Either compile on your own or use precompiled deb file
a.

sudo apt install qt5-qmake qtbase5-dev
sudo apt install libqt5serialport5-dev
sudo apt update && sudo apt install -y \
  qtbase5-dev \
  qtchooser \
  qttools5-dev-tools \
  libqt5serialport5-dev \
  build-essential \
  pkg-config \
  libusb-1.0-0-dev \
  libudev-dev \
  gnome-shell-extension-appindicator \
  libpulse-dev \
  libfftw3-dev
sudo apt-get install hashdeep


git clone https://github.com/psieg/Lightpack.git ~/lightpack
~/lightpack/Software/dist_linux/build-natively.sh dpkg


b.

sudo apt-get install libappindicator1
sudo apt update
sudo apt-get install -f


cd ~/lightpack/Software/dist_linux/dpkg  
nano deb/DEBIAN/control
amd64-> armhf

dpkg-deb --build deb prismatik_armhf.deb

3. 
finally install
dpkg-deb --build deb prismatik_armhf.deb


4. Add to Autostart
Create file /etc/systemd/system/prismatik.service

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable lightpack-rest
sudo systemctl start lightpack-rest

5. Restart device
Prismatik should start 2-3 Minutes after raspberry has launched.
Dont forget to enable developer settings to activate http controler
