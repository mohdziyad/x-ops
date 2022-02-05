output "rds_endpoint" {
  description = "RDS endpoint to be used to load data to db"
  value       = module.db.db_instance_address
}

output "repository_url" {
  description = "Output of ECR repo URL for use with dockerfile push command"
  value       = aws_ecr_repository.xops.repository_url
}

output "db_agent_ip" {
  description = "Output of DB Agent IP address"
  value       = aws_instance.db_agent.public_ip
}