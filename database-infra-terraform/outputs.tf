output "rds_endpoint" {
  description = "RDS endpoint to be used to load data to db"
  value       = module.db.db_instance_address
}

output "repository_url" {
  description = "Output of ECR repo URL for use with dockerfile push command"
  value       = aws_ecr_repository.xops.repository_url
}

output "bastion_host_ip" {
  description = "Output of Bastion host IP address"
  value       = aws_instance.bastion_host.public_ip
}