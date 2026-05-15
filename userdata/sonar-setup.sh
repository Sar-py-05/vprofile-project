#!/bin/bash

set -e

echo "==============================="
echo "Updating system packages"
echo "==============================="

apt update -y

echo "==============================="
echo "Kernel tuning for SonarQube"
echo "==============================="

cp /etc/sysctl.conf /root/sysctl.conf_backup || true

grep -q "vm.max_map_count=262144" /etc/sysctl.conf || cat <<EOT >> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
EOT

sysctl -p

cp /etc/security/limits.conf /root/sec_limit.conf_backup || true

grep -q "sonar" /etc/security/limits.conf || cat <<EOT >> /etc/security/limits.conf
sonar   -   nofile   65536
sonar   -   nproc    4096
EOT

echo "==============================="
echo "Installing Java 21 + utilities"
echo "==============================="

apt install openjdk-21-jdk unzip curl wget nginx ufw gnupg lsb-release ca-certificates -y

java -version

echo "==============================="
echo "Installing PostgreSQL"
echo "==============================="

install -d /usr/share/postgresql-common/pgdg

curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
| gpg --dearmor \
-o /usr/share/postgresql-common/pgdg/postgresql.gpg

echo "deb [signed-by=/usr/share/postgresql-common/pgdg/postgresql.gpg] \
http://apt.postgresql.org/pub/repos/apt \
$(lsb_release -cs)-pgdg main" \
> /etc/apt/sources.list.d/pgdg.list

apt update -y

apt install postgresql postgresql-contrib -y

systemctl enable postgresql
systemctl start postgresql

echo "==============================="
echo "Configuring PostgreSQL DB"
echo "==============================="

runuser -u postgres -- createuser sonar || true

sudo -u postgres psql -c \
"ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"

sudo -u postgres psql -tc \
"SELECT 1 FROM pg_database WHERE datname='sonarqube'" \
| grep -q 1 || sudo -u postgres createdb -O sonar sonarqube

echo "==============================="
echo "Downloading SonarQube"
echo "==============================="

mkdir -p /sonarqube
cd /sonarqube

if [ ! -f sonarqube-26.4.0.121862.zip ]; then
    curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-26.4.0.121862.zip
fi

rm -rf /opt/sonarqube

unzip -o sonarqube-26.4.0.121862.zip -d /opt/

mv /opt/sonarqube-26.4.0.121862 /opt/sonarqube

echo "==============================="
echo "Creating Sonar user"
echo "==============================="

groupadd sonar || true

id sonar &>/dev/null || useradd \
-c "SonarQube User" \
-d /opt/sonarqube \
-g sonar sonar

chown -R sonar:sonar /opt/sonarqube

chmod 1777 /tmp

echo "==============================="
echo "Configuring sonar.properties"
echo "==============================="

cp /opt/sonarqube/conf/sonar.properties \
/root/sonar.properties_backup || true

cat <<EOT > /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube

sonar.web.host=0.0.0.0
sonar.web.port=9000

sonar.web.javaAdditionalOpts=-server -Xmx1024m
sonar.search.javaOpts=-Xms512m -Xmx512m

sonar.log.level=INFO
sonar.path.logs=logs
EOT

echo "==============================="
echo "Creating systemd service"
echo "==============================="

cat <<EOT > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube Service
After=network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable sonarqube
systemctl restart sonarqube

echo "==============================="
echo "Configuring Nginx"
echo "==============================="

rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

cat <<EOT > /etc/nginx/sites-available/sonarqube
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:9000;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOT

ln -sf /etc/nginx/sites-available/sonarqube \
/etc/nginx/sites-enabled/sonarqube

nginx -t

systemctl enable nginx
systemctl restart nginx

echo "==============================="
echo "Opening firewall ports"
echo "==============================="

ufw allow 80/tcp || true
ufw allow 9000/tcp || true

echo "==============================="
echo "Waiting for SonarQube startup"
echo "==============================="

sleep 60

systemctl status sonarqube --no-pager

echo "==============================="
echo "SonarQube Installation Complete"
echo "==============================="
echo "Access URL:"
echo "http://$(curl -s ifconfig.me)"
echo "http://$(curl -s ifconfig.me):9000"
