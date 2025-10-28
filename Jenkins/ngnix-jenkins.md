server {
    listen 80;
    server_name pranab.jenkins;

    location / {
        proxy_pass http://192.168.1.13:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}





http://pranab.jenkins.org/


openssl pkcs12 -export \
  -in server.crt \
  -inkey server.key \
  -out jenkins-keystore.p12 \
  -name jenkins \
  -password pass:changeit


keytool -importkeystore \
  -srckeystore jenkins-keystore.p12 \
  -srcstoretype PKCS12 \
  -srcstorepass changeit \
  -destkeystore /var/lib/jenkins/jenkins.jks \
  -deststoretype JKS \
  -deststorepass changeit




sudo chown jenkins:jenkins /var/lib/jenkins/jenkins.jks
sudo chmod 600 /var/lib/jenkins/jenkins.jks

sudo vim /etc/default/jenkins

JENKINS_ARGS="--webroot=/var/cache/$NAME/war \
  --httpPort=-1 \
  --httpsPort=8443 \
  --httpsKeyStore=/var/lib/jenkins/jenkins.jks \
  --httpsKeyStorePassword=changeit"



sudo systemctl restart jenkins



cat /etc/nginx/sites-available/jenkins

https://pranab.jenkins.org:8443/





# Redirect all HTTP traffic to HTTPS
server {
    listen 80;
    server_name pranab.jenkins.org;

    return 301 https://$host$request_uri;
}

# HTTPS configuration
server {
    listen 443 ssl;
    server_name pranab.jenkins.org;

    # Paths to your SSL certs
    ssl_certificate     /var/lib/jenkins/cert/server.crt;
    ssl_certificate_key /var/lib/jenkins/cert/server.key;

    # Recommended SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass         http://192.168.1.13:8080;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto https;

        # Jenkins-specific optimizations
        proxy_redirect     http:// https://;
        proxy_buffering    off;
        proxy_request_buffering off;
    }
}


https://pranab.jenkins.org/





