<h1>Xeneta operations task overview</h1>
The environment for the Python API is setup in AWS EKS. Database is RDS Postrgresql 13.5 </br>

<b>Tools usage</b>
- IaC - Terraform
- Containers - Docker
- Deployment environment - Elastice Kubernetes Service
- Database - RDS Postgresql
- RDS Data load - via DB Agent EC2
- Kubernetes ingress controller - ALB
- Kubernetes Deployment - Helm

<h1> Services and Modules usage </h1>

```sh
For details on the AWS Services used and the deployment, please refer the Use-case-1.docx
```

<h1>Prerequisites</h1>


> Terraform version >=0.14</br>
> AWS CLI with credentials configured </br>
> Docker installation with CLI </br>
> Kubectl CLI </br>
> Linux command line </br>

1) Create an SSM Parameter with name "dbpwd" and store a password for database.
2) Base64 encode db password for use in kubernetes manifest.
3) Set the .kube directory to eks-cluster-terraform directory for helm authentication. (OR move the .kube directory from user dir)
4) Clone the GIT repo

<h1>Installation Steps</h1> </br>

(Use Linux command line like GIT bash to execute the commands)</br>
Deploy the terraform backend s3 bucket and dynamob table for locking the state files
```sh
cd backend-terraform
terraform init; terraform plan; terraform apply
```

Deploy VPC, Database, s3 bucket, DB agent Host to load data and ECR repository
```sh
cd database-infra-terraform
terraform init ; terraform plan ; terraform apply
```
Build the docker image and push to ECR. Run the below shell script
```sh
sh docker_image_push_to_ecr.sh
```

Deploy EKS Cluster and related resources and update kubeconfig.:
```sh
cd eks-cluster-terraform
terraform init; terraform plan; terraform apply
aws eks --region us-east-2 update-kubeconfig --name $(terraform output -raw cluster_name)
```

Deploy Configuration in EKS Cluster using helm terraform:</br>
```sh
cd helm-terraform
```
- Make sure .kube directory is upto date with updated kubeconfig.</br>
- If the directory is in user home, move the updated one to this location </br>
- Put the base64 encoded password into line number #6 (dbpwd) of values.yml
```sh
terraform init; terraform plan; terraform apply
```

Verify the application.</br>
- kubectl get ingress -n rates (Check the hostname in the output) </br>
- After few minutes (Once the ALB becomes "Active"), Goto browser and access application using alb dns name: (<b>http://albdnsname/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL</b>)


<h1> Data Ingestion Pipeline </h1>

```sh
Please refer the document Use-case-2.docx
```
