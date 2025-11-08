#!/bin/bash
# ==========================================================
# MASTER DEPLOYMENT SCRIPT — Install & Deploy Tomcat App on All EC2s
# ==========================================================

cd $WORKSPACE/Tomcat
ls -ltr
export AWS_DEFAULT_REGION="us-west-2"
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export PEM_KEY="id_rsa"

# ----------------------------------------------------------
# STEP 1: Fetch Running EC2 Public IPs
# ----------------------------------------------------------
echo "Fetching running EC2 instance IPs..."
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text > ec2.txt

echo "Found the following instances:"
cat ec2.txt

# ----------------------------------------------------------
# STEP 2: Loop through each instance and deploy
# ----------------------------------------------------------
for instance in $(cat ec2.txt); do
  echo "=============================================="
  echo "🚀 Deploying on $instance"
  echo "=============================================="

  scp -o StrictHostKeyChecking=no -i $PEM_KEY deploy_tomcat_single.sh ubuntu@$instance:/tmp/
  ssh -o StrictHostKeyChecking=no -i $PEM_KEY ubuntu@$instance "bash /tmp/deploy_tomcat_single.sh"
done

echo "✅ All deployments completed successfully!"
