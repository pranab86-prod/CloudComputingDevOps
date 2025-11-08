#!/bin/bash
set -e
echo "===== Starting Tomcat setup on $(hostname) ====="

# -------------------- INSTALL JAVA --------------------
sudo apt update -y
sudo apt install -y openjdk-17-jdk wget curl
java -version

# -------------------- CREATE TOMCAT USER --------------------
sudo groupadd --system tomcat || true
sudo useradd -s /bin/false -g tomcat --system -d /opt/tomcat tomcat || true

# -------------------- INSTALL TOMCAT --------------------
TOMCAT_MAJOR=9
TOMCAT_VERSION=9.0.111

sudo mkdir -p /opt/tomcat
cd /tmp
wget https://downloads.apache.org/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
sudo tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat
sudo ln -sfn /opt/tomcat/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat/latest
sudo chown -R tomcat:tomcat /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}
sudo chmod -R g+r /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}/conf
sudo chmod g+x /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}/conf

# -------------------- SYSTEMD SERVICE --------------------
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

sudo systemctl daemon-reload
sudo systemctl enable --now tomcat

# -------------------- DEPLOY SAMPLE APP --------------------
cd /tmp
curl -L -o sample-tomcat-app.war https://raw.githubusercontent.com/pranab86-prod/CloudComputingDevOps/main/Tomcat/sample-tomcat-app.war
sudo mv sample-tomcat-app.war /opt/tomcat/latest/webapps/
sudo chown tomcat:tomcat /opt/tomcat/latest/webapps/sample-tomcat-app.war

sudo mkdir -p /opt/tomcat/latest/webapps/ROOT/WEB-INF
sudo curl -L -o /opt/tomcat/latest/webapps/ROOT/index.html https://raw.githubusercontent.com/pranab86-prod/CloudComputingDevOps/main/Tomcat/index.html
sudo curl -L -o /opt/tomcat/latest/webapps/ROOT/WEB-INF/web.xml https://raw.githubusercontent.com/pranab86-prod/CloudComputingDevOps/main/Tomcat/web.xml
sudo chown -R tomcat:tomcat /opt/tomcat/latest/webapps/

# -------------------- RESTART TOMCAT --------------------
sudo systemctl restart tomcat
sleep 10

if systemctl is-active --quiet tomcat; then
  echo "✅ Tomcat running successfully on $(hostname)"
else
  echo "❌ Tomcat failed to start. Check logs at /opt/tomcat/latest/logs/catalina.out"
fi
