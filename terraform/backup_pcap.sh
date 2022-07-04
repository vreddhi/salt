#!/bin/bash

sudo apt update
sudo apt install git -y

cd /home/ubuntu
git clone https://github.com/vreddhi/salt.git
cd salt
sudo chmod a+x tcpdump.sh

sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

curl "https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux" -o "sops"
sudo sops /usr/local/bin/
sudo chmod a+x /usr/local/bin/sops

sops exec-env env.json 'bash'
sudo ./tcpdump.sh