🖥️ Step 1 – Launch EC2 & install ttyd

Go to EC2 → Instances → Launch instance

Name: ttyd-server

AMI: Amazon Linux 2 (64-bit x86)

Instance type: t3.micro (or bigger if needed)

Key pair: select existing or create new

Network settings:

Choose your VPC

Subnet: pick one public subnet

Security group: create new with:

Inbound rule: allow SSH (22) from your IP

Inbound rule: allow Custom TCP 8443 from your ALB SG (later) or 0.0.0.0/0 temporarily for testing

Storage: default 8 GB is fine

User data (Advanced details → User data) → paste:

#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
systemctl enable --now docker
usermod -aG docker ec2-user
docker run -d --restart unless-stopped --name ttyd -p 8443:7681 tsl0922/ttyd:latest -p 7681 -- /bin/bash


Launch instance

🔍 Wait until the instance is Running → test via PublicIP:8443 (https://<public-ip>:8443) → you should see ttyd.

🖥️ Step 2 – Create Target Group

Go to EC2 → Target Groups → Create target group

Choose:

Target type: Instances

Protocol: HTTP

Port: 8443

VPC: select your VPC

Protocol version: HTTP1

Health checks:

Protocol: HTTP

Path: /

Port: 8443

Create Target Group

On the next screen, Register targets → select your EC2 instance → port 8443 → Add → Save

🖥️ Step 3 – Create Application Load Balancer (ALB)

Go to EC2 → Load Balancers → Create Load Balancer

Choose Application Load Balancer

Name: ttyd-alb

Scheme: Internet-facing

IP address type: IPv4

Network:

Select same VPC as EC2

Pick 2 subnets (different AZs)

Security group:

Create/select ALB SG with Inbound rule: HTTPS (443) from 0.0.0.0/0

Listeners:

Protocol: HTTPS

Port: 443

Certificate: Request a new ACM certificate for your domain (or pick existing if you already requested one)

Default action: Forward → your Target Group

Create Load Balancer

🖥️ Step 4 – ACM Certificate

If you requested a new ACM certificate during ALB creation:

Go to ACM → Certificates

Find your domain (e.g. pranab.devops.975050238435.realhandsonlabs.net)

Validation: DNS validation

Click “Create record in Route53” (if your hosted zone is in the same account)

Wait a few minutes → status should change to Issued

Once issued, the ALB listener will automatically start using it.

🖥️ Step 5 – Route53 DNS

Go to Route53 → Hosted zones

Open your hosted zone for realhandsonlabs.net

Create record:

Record name: pranab.devops.975050238435 (so full FQDN matches your ACM cert)

Record type: A – IPv4

Alias: Yes

Alias target: pick your ALB (it will show up in the dropdown)

Save

✅ Test

Wait until Target Group shows Healthy

Open browser:

https://pranab.devops.975050238435.realhandsonlabs.net


You should now see ttyd without :8443.
