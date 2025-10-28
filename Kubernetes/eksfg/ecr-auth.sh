# 1. Authenticate Docker to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 851725578224.dkr.ecr.us-west-2.amazonaws.com

# 2. Create ECR repository (only once)
#aws ecr create-repository --repository-name nginx-demo

# 3. Build the Docker image
docker build -t prod/ecr0 .

# 4. Tag the image for ECR
docker tag prod/ecr0:latest 851725578224.dkr.ecr.us-west-2.amazonaws.com/prod/ecr0:latest

# 5. Push the image to ECR
docker push 851725578224.dkr.ecr.us-west-2.amazonaws.com/prod/ecr0:latest
