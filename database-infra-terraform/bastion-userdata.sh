#!/bin/bash

#Create EPEL release
echo "Creating EPEL release"
sudo amazon-linux-extras install epel -y

#Add postgresql13 to EPEL release
echo "Adding postgresql13 to EPEL repo"
sudo tee /etc/yum.repos.d/pgdg.repo<<EOF
[pgdg13]
name=PostgreSQL 13 for RHEL/CentOS 7 - x86_64
baseurl=http://download.postgresql.org/pub/repos/yum/13/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0
EOF

#Install psql13 client for connecting to RDS postgresql
echo "installing postgresql13 client"
sudo yum install postgresql13 -y