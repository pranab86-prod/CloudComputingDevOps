#!/bin/bash
echo "Please update AWS configue ######################################"
sudo chmod 777 /var/run/docker.sock
ecrUri="590183727102.dkr.ecr.us-west-2.amazonaws.com/prd/tom80"
url=$(echo $ecrUri  | cut -d "/" -f1)
# 1. Authenticate Docker to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $url

# 2. Create ECR repository (only once)
#aws ecr create-repository --repository-name nginx-demo

# 3. Build the Docker image
docker build -t prd/tom80 .

# 4. Tag the image for ECR
docker tag prd/tom80:latest $ecrUri

# 5. Push the image to ECR
docker push $ecrUri
