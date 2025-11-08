#!/bin/bash
set -e
set -o pipefail

echo "===== Updating packages and installing Java ====="
sudo apt update -y
sudo apt install -y openjdk-17-jdk curl wget tar

echo "Java version:"
java -version

echo "===== Creating Tomcat user and directories ====="
sudo groupadd --system tomcat || true
sudo useradd -s /bin/false -g tomcat --system -d /opt/tomcat tomcat || true

sudo mkdir -p /opt/tomcat
sudo chown root:root /opt/tomcat

echo "===== Downloading and installing Tomcat ====="
TOMCAT_MAJOR=9
TOMCAT_VERSION=9.0.89   # ✅ stable version (111 not yet available)
cd /tmp

wget -q https://downloads.apache.org/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

sudo tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat
sudo ln -sfn /opt/tomcat/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat/latest

sudo chown -R tomcat:tomcat /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}
sudo chmod -R g+r /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}/conf
sudo chmod g+x /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}/conf

echo "===== Creating Tomcat systemd service ====="
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<'EOF'
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "===== Starting Tomcat ====="
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat
sudo systemctl status tomcat --no-pager

echo "===== Deploying sample app ====="
# WAR deployment
sudo curl -L -o /tmp/sample-tomcat-app.war https://raw.githubusercontent.com/pranab86-prod/CloudComputingDevOps/main/Tomcat/sample-tomcat-app.war
sudo mv /tmp/sample-tomcat-app.war /opt/tomcat/latest/webapps/
sudo chown tomcat:tomcat /opt/tomcat/latest/webapps/sample-tomcat-app.war

# index.html deployment
sudo mkdir -p /opt/tomcat/latest/webapps/ROOT
sudo curl -L -o /opt/tomcat/latest/webapps/ROOT/index.html https://raw.githubusercontent.com/pranab86-prod/CloudComputingDevOps/main/Tomcat/index.html
sudo chown tomcat:tomcat /opt/tomcat/latest/webapps/ROOT/index.html
# WEB-INF/web.xml deployment
sudo mkdir -p /opt/tomcat/latest/webapps/ROOT/WEB-INF
sudo curl -L -o /opt/tomcat/latest/webapps/ROOT/WEB-INF/web.xml https://raw.githubusercontent.com/pranab86-prod/CloudComputingDevOps/main/Tomcat/web.xml
sudo chown tomcat:tomcat /opt/tomcat/latest/webapps/ROOT/WEB-INF/web.xml
echo "===== Restarting Tomcat ====="
sudo systemctl restart tomcat
sleep 10

echo "===== Checking if Tomcat is running ====="
if systemctl is-active --quiet tomcat; then
    echo "✅ Tomcat is running and WAR deployed successfully!"
else
    echo "❌ Tomcat failed to start. Check logs at: /opt/tomcat/latest/logs/catalina.out"
fi
