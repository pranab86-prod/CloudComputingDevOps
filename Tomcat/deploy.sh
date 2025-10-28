sudo apt update
sudo apt install openjdk-17-jdk -y
java -version  # verify Java is installed



# Create group and user (no login)
sudo groupadd --system tomcat
sudo useradd -s /bin/false -g tomcat --system -d /opt/tomcat tomcat

# Create installation dir
sudo mkdir -p /opt/tomcat
sudo chown root:root /opt/tomcat

# Example: set version (change to the version you want)
TOMCAT_MAJOR=9
TOMCAT_VERSION=9.0.111   # example; check https://tomcat.apache.org/ for latest
cd /tmp
wget https://downloads.apache.org/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
# verify download (optional, recommended in production): check PGP or SHA512 from tomcat site
sudo tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat
# create a symlink for convenience
sudo ln -s /opt/tomcat/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat/latest
sudo chown -R tomcat:tomcat /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}
sudo chmod -R g+r /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}/conf
sudo chmod g+x /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}/conf



sudo tee /etc/systemd/system/tomcat.service > /dev/null <<'EOF'
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64"
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

# reload systemd and start Tomcat
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat
sudo systemctl status tomcat


# from your laptop
#scp -i /path/to/your-key.pem sample-tomcat-app.war ubuntu@<EC2_PUBLIC_IP>:/tmp/

# on the EC2 instance
sudo mv /tmp/sample-tomcat-app.war /opt/tomcat/latest/webapps/
sudo chown tomcat:tomcat /opt/tomcat/latest/webapps/sample-tomcat-app.war

# Tomcat will automatically explode and deploy the WAR. Check logs if not:
#tail -n 200 /opt/tomcat/latest/logs/catalina.out
