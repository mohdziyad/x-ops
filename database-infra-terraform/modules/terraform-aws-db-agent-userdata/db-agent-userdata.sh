#!/bin/bash

#Vars for s3 bucket and rds connection string
S3_BUCKET="${s3_bucket}" 
RDS_PG_PASSWORD="${rds_pwd}" 
RDS_END_POINT="${rds_address}" 
RDS_USER="${rds_user}" 
RDS_DB_NAME="${rds_db}" 

#Install SSM agent on EC2
echo "Installing SSM Agent to connect to EC2 using Session Manager"
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

#Create EPEL release
echo "Creating EPEL release"
sudo amazon-linux-extras install epel -y

#Add postgresql13 to EPEL release
sudo tee /etc/yum.repos.d/pgdg.repo<<EOF
[pgdg13]
name=PostgreSQL 13 for RHEL/CentOS 7 - x86_64
baseurl=http://download.postgresql.org/pub/repos/yum/13/redhat/rhel-7-x86_64
enabled=1
gpgcheck=0
EOF
echo "Installing Postgres 13"
sudo yum install postgresql13 -y

#Install AWS CLI
echo "Installing AWS CLI"
if command -v aws >/dev/null; then
    echo 'AWS-CLI already installed...'
    return
  fi
echo "Installing aws cli..."
curl -o awscli-bundle.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
sudo yum install -y unzip
sudo unzip -o awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
sudo chmod +x /usr/bin/aws
sudo /usr/bin/aws --version
which aws
whoami

#Download data file from S3
echo "downloading db file from S3 to import into RDS Postgres"
aws s3 cp s3://$${S3_BUCKET}/rates.sql /tmp/rates.sql
sudo chmod 644 /tmp/rates.sql

#Import Data into Database
echo "Import Data into RDS Postgres"
export PGPASSWORD=$${RDS_PG_PASSWORD};
psql -h $${RDS_END_POINT} -p 5432 -U $${RDS_USER} -d $${RDS_DB_NAME} < /tmp/rates.sql