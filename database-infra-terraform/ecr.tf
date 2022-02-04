resource "aws_ecr_repository" "xops" {
  name                 = "x-ops-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" {
  description = "Output of ECR repo URL for use with dockerfile push command"
  value       = aws_ecr_repository.xops.repository_url
}