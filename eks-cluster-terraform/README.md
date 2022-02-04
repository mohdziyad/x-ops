<h3>Terraform Code to create EKS Cluster, Worker nodes and all required IAM Roles and Network services like VPC, Subnets, NAT Gateway, etc.</h3>

<br>

To add EKS Cluster context to Kubeconfig, run the command below after the infrastructure is launched:
<br>

<b>aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)</b>


<h2>Versions</h2>
Terraform - 1.0.11
hashicorp/aws - 3.71
hashicorp/kubernetes - 2.7.1