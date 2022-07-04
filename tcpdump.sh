#!/bin/bash
# Send TCP dumps to S3

die() { status=$1; shift; echo "FATAL: $*"; exit $status; }

# Replace with actual bucket name
BUCKET_NAME="vb-testbucket";
RANDOM=$$
# Get instance id
INSTANCE_ID="EC2"
# Init temp file
sudo touch temp.pcap

while true :
do
  # Capture 50 packets
  sudo tcpdump -i ens5 -w temp.pcap -G 30 port 4789

  # Build filename
  YEAR=$(date +%Y);
  MONTH=$(date +%m);
  DAY=$(date +%d);
  HOUR=$(date +%H);
  MINUTE=$(date +%M);
  S3_KEY="s3://${BUCKET_NAME}/${INSTANCE_ID}/${YEAR}/${MONTH}/${DAY}/${HOUR}:${MINUTE}-${RANDOM}.pcap";
  # Upload file to bucket with date
  echo "Writing temp.pcap to ${S3_KEY}"
  aws s3 cp --quiet temp.pcap $S3_KEY
  # Clear temp pcap
  sudo rm -f temp.pcap
done