<h1>Xeneta operations task overview</h1>
The environment for the Python API is setup in AWS EKS in us-east-2 region. Database is RDS Postrgresql 13.5 </br>

<u>AWS Services and other tools used</u>
- IaaC - Terraform
- Containers - Docker
- Deployment environment - Elastice Kubernetes Service
- Database - RDS Postgresql
- RDS Data load - via Bastion host since RDS is in private subnet
- Kubernetes ingress controller - ALB

<h1>Prerequisites</h1>

Terraform version >=0.14</br>
AWS CLI with credentials configured </br>
Kubectl CLI

1) Create a key pair in AWS
2) Create an SSM Parameter with name "dbpwd" and store a password for database.
3) Base64 encode db password for use in kubernetes manifest.
4) Move the pem file to database-infra-terraform directory for bastion host access for copying the sql file
5) Move .kube directory to eks-cluster-terraform directory for helm authentication.
6) Clone the GIT repo

<h1>Installation Steps</h1> </br>

(Use Linux command line like GIT bash to execute the commands)</br>
Deploy VPC, Database, Bastion Host to load data and ECR repository
```sh
cd database-infra-terraform
terraform init ; terraform plan ; terraform apply
```

ssh to bastion  host and load the db:
```sh
ssh -i yourpem.pem ec2-user@$(terraform output -raw bastion_host_ip)
psql -h rds_address -U postgres -d rates < /tmp/rates.sql
```
(Enter the db password when prompted)

Build the docker image and push to ECR. Execute the following commands
```sh
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $(terraform output -raw repository_url | sed 's/x-ops-repo$//')
docker build -t x-ops-repo ../.
docker tag x-ops-repo:1.0 $(terraform output -raw repository_url):1.0
docker push $(terraform output -raw repository_url):1.0
```

Deploy EKS Cluster and related resources and update kubeconfig:
```sh
cd eks-cluster-terraform
terraform init; terraform plan; terraform apply
aws eks --region us-east-2 update-kubeconfig --name $(terraform output -raw cluster_name)
```

Deploy Configuration in EKS Cluster using helm terraform:</br>
```sh
cd helm-terraform
```
Make sure .kube directory is upto date with updated kubeconfig.</br>
Put the base64 encoded password into line number #6 (dbpwd) of values.yml
```sh
terraform init; terraform plan; terraform apply
```

Verify the application.</br>
- kubectl get ingress -n rates (Check the hostname in the output) </br>
- After few minutes (Once the ALB becomes "Active"), Goto browser and access application using alb dns name: (<b>http://albdnsname/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL</b>)