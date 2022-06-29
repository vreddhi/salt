#!/bin/bash
# Send TCP dumps to S3

die() { status=$1; shift; echo "FATAL: $*"; exit $status; }

# Replace with actual bucket name
BUCKET_NAME="vb-testbucket";
# Get instance id
INSTANCE_ID="EC2"
# Init temp file
touch temp.pcap

while true :
do
  # Capture 5k packets
  sudo tcpdump -i ens5 -w temp.pcap -c 5000 port 80

  # Build filename
  YEAR=$(date +%Y);
  MONTH=$(date +%m);
  DAY=$(date +%d);
  HOUR=$(date +%H);
  MINUTE=$(date +%M);
  S3_KEY="s3://${BUCKET_NAME}/${INSTANCE_ID}/${YEAR}/${MONTH}/${DAY}/${HOUR}:${MINUTE}-${INSTANCE_ID}.pcap";
  # Upload file to bucket with date
  echo "Writing temp.pcap to ${S3_KEY}"
  aws s3 cp --quiet temp.pcap $S3_KEY
  # Clear temp pcap
  rm -f temp.pcap
done