
🔹 Step 1: Prepare Your App
Example Dockerfile for Tomcat frontend

Dockerfile

FROM tomcat:9.0-jdk11
COPY ./myapp.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]


Build and test locally:

docker build -t my-tomcat-app .
docker run -p 8080:8080 my-tomcat-app

🔹 Step 2: Install Copilot

(as shown earlier)

curl -Lo copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux && chmod +x copilot && sudo mv copilot /usr/local/bin/copilot && copilot --help

🔹 Step 3: Initialize Copilot App
copilot init


Choose:

Application Name → myapp

Service Type → Load Balanced Web Service

Service Name → frontend

Dockerfile → ./Dockerfile

This creates:

copilot/
  frontend/manifest.yml

🔹 Step 4: Configure Manifest

Open copilot/frontend/manifest.yml and adjust:

name: frontend
type: Load Balanced Web Service

image:
  build: ./Dockerfile
  port: 8080

cpu: 512
memory: 1024
count: 2   # Number of ECS tasks (like replicas)

http:
  path: '/'
  healthcheck: '/'
  alias: myapp.example.com   # Optional, if using Route53

variables:
  DB_HOST: "mydb.cluster-xxxx.ap-south-1.rds.amazonaws.com"
  DB_NAME: "mydb"
  DB_USER: "myuser"
secrets:
  DB_PASSWORD: /copilot/myapp/prod/secrets/db_password

🔹 Step 5: Deploy Frontend
copilot deploy --name frontend


After deployment:

copilot svc show --name frontend


➡ You’ll get the ALB URL to access Tomcat.

🔹 Step 6: Setup PostgreSQL Backend

Copilot doesn’t directly create RDS, but you can do:

Option 1: Use AWS RDS manually
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-name mydb \
  --engine postgres \
  --master-username myuser \
  --master-user-password mypassword \
  --allocated-storage 20 \
  --db-instance-class db.t3.micro


Store password in AWS SSM Parameter Store:

aws ssm put-parameter \
  --name "/copilot/myapp/prod/secrets/db_password" \
  --value "mypassword" \
  --type "SecureString"

Option 2: Use Copilot Job (batch DB migration/init script)
copilot job init --name db-migrate --dockerfile ./db/Dockerfile --schedule "once"

🔹 Step 7: Verify DB Connection

Tomcat app should connect using env variables:

String url = "jdbc:postgresql://" + System.getenv("DB_HOST") + ":5432/" + System.getenv("DB_NAME");
Connection conn = DriverManager.getConnection(url, System.getenv("DB_USER"), System.getenv("DB_PASSWORD"));

#####################################3

