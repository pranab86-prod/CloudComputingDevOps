sudo apt update -y
sudo apt install -y build-essential cmake git libjson-c-dev libwebsockets-dev

git clone https://github.com/tsl0922/ttyd.git
cd ttyd
mkdir build && cd build
cmake ..
make
sudo make install



ttyd --writable -p 8443 bash

ttyd --writable --ssl --ssl-cert cert.crt --ssl-key cert.key -p 8443 bash

sudo apt update
sudo apt install nginx
