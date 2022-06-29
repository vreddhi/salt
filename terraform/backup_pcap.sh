#!/bin/bash

sudo apt update
sudo apt install git -y

cd /home/ubuntu
git clone https://github.com/vreddhi/salt.git

sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install