# AWS Infrastructure to setup Traffic Mirroring

This repository contains terraform code to provison AWS resources.
Following are the details of individual files.

1. vpc.tf : Provisions VPC, subnets, routetable(s) needed
2. security_group.tf : Provisons the necessary ingress and egress rules for resources to communicate
3. instance.tf : Provisons 2 EC2 servers, in appropriate VPC and subnets 
4. eip.tf : Reads the elastic IP variable and associates it to two EC2 machines
5. traffic_mirror.tf : Provisions the Traffic mirror filter, rule, target and the session.
6. variables.tf : hosts all the variables needed for this setup

7. backup_pcap.sh : A shell script which runs tcpdump indefinitely filtering traffic on port 4789
8. reverse_proxy.sh : A post bootup script, that installs docker and runs a reverse proxy nginx server

Further there is a simple docker file, which uses vanilla nginx and copies a custom configuration file to passthough all the requests, to ensure the reverse proxy is setup.