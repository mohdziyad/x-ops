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
4) Move the pem file database-infra-terraform directory for bastion host access for copying the sql file
5) Move .kube directory to eks-cluster-terraform directory
6) Clone the GIT repo

<h1>Installation Steps</h1> </br>

1) Deploy VPC, Database, Bastion Host to load data and ECR repository
- cd database-infra-terraform </br>
- terraform init </br>
- terraform plan </br>
- terraform apply </br>

2) ssh to bastion  host (get the ip from output) and load the db using following command
- psql -h rds_address_name -U postgres -d rates < /tmp/rates.sql 

3) Build the docker image and push to ECR. Execute the following commands

- aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin accountnumber.dkr.ecr.us-east-2.amazonaws.com </br>

- docker build -t x-ops-repo:1.0 .
- docker tag x-ops-repo:1.0 accountnumber.dkr.ecr.us-east-2.amazonaws.com/x-ops-repo:1.0
- docker push accountnumber.dkr.ecr.us-east-2.amazonaws.com/x-ops-repo:latest

4) Deploy EKS Cluster and related resources:
- cd eks-cluster-terraform
- terraform init, plan and apply

5) Deploy Configuration in EKS Cluster using helm terraform
- cd helm/terraform-helm
- Put the base64 encoded password into line number #12 of alb_ingress_controller_custom_values.yml
- terraform init, plan and apply

6) Verify the application.
- kubectl get ingress -n rates (Check the hostname in the output)
- Goto browser and access application using alb dns name (<b>http://dnsname/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL</b>)