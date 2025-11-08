#!/bin/bash
cd $WORKSPACE/Tomcat
ls -ltr
export AWS_DEFAULT_REGION="us-west-2"
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
# Step 1: Get all EC2 instance public IPs and save to ec2.txt
aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].{InstanceID:InstanceId, Name:Tags[?Key=='Name']|[0].Value, State:State.Name, PublicIP:PublicIpAddress}" \
  --output table | awk '{print $5}' | sed -n '6,$p' > ec2.txt

sudo chmod 400 id_rsa 
# Step 2: Loop through each IP and run deploy.sh remotely
for instance in $(cat ec2.txt)
do
  echo "==============================="
  echo "Deploying on $instance..."
  echo "==============================="

  # Copy deploy.sh to remote server
  scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i id_rsa deploy.sh ubuntu@$instance:/tmp/

  # Execute deploy.sh on remote
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i id_rsa ubuntu@$instance "bash /tmp/deploy.sh"
done
