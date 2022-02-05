
#!/bin/bash
AWS_REGION="us-east-2"

echo "Login to ECR"
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $(terraform output -raw repository_url | sed 's/x-ops-repo$//')

echo "Build Docker Image"
docker build -t x-ops-repo ../.

echo "Tag your image so you can push the image to this repository"
docker tag x-ops-repo:1.0 $(terraform output -raw repository_url):1.0

echo "Push Docker Image to ECR"
docker push $(terraform output -raw repository_url):1.0