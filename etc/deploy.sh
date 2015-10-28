#!/bin/sh
HOST=aws
VERSION=0.1.0-SNAPSHOT
setup() {
    ssh "${HOST}" <<SHELL
echo "Asia/Tokyo" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

sudo apt-get update
sudo apt-get -i upgrade
sudo apt-get install -y nginx mysql-server openjdk-7-jdk supervisor
curl -fsSL https://mackerel.io/assets/files/scripts/setup-apt.sh | sh
sudo apt-get install -y mackerel-agent mackerel-plugins

# fluentd for mackerel
sudo apt-get install -y build-essential ruby2.0-dev
sudo gem2.0 install fluentd fluent-plugin-mackerel fluent-plugin-datacounter
SHELL
}

deploy() {
    scp ../target/b11d-${VERSION}-standalone.jar schema.sql "${HOST}:"
}

seed_db() {

    ssh "${HOST}" <<SHELL
mysql -uroot < schema.sql
java -cp b11d-${VERSION}-standalone.jar clojure.main -e "(use 'b11d.importer)(-main)"
SHELL
}

nginx(){
    ssh "${HOST}" <<SHELL
    cat <<'EOF' | sudo tee /etc/nginx/nginx.conf
$(cat nginx.conf)
EOF
    sudo service nginx restart

SHELL
    
}

supervisord(){
    ssh "${HOST}" <<SHELL
    cat <<'EOF' | sudo tee /etc/supervisor/supervisord.conf
$(cat supervisord.conf | sed "s/\${VERSION}/${VERSION}/")
EOF
    sudo service supervisor restart
SHELL
}

mysql(){
    ssh "${HOST}" <<SHELL
    cat <<'EOF' | sudo tee /etc/mysql/my.cnf
$(cat my.cnf)
EOF
    sudo service mysql restart
SHELL
}

mackerel(){
    ssh "${HOST}" <<SHELL
    cat <<'EOF' | sudo tee /etc/mackerel-agent/mackerel-agent.conf
$(cat mackerel-agent.conf)
EOF
    sudo sed -i'' "1s:\\\$:\$(cat /home/ubuntu/MACKEREL_APIKEY):" /etc/mackerel-agent/mackerel-agent.conf
    sudo service mackerel-agent restart
SHELL
}

fluentd(){
    ssh "${HOST}" <<SHELL
    cat <<'EOF' | sudo tee /etc/fluent/fluent.conf
$(cat fluent.conf)
EOF
    sudo sed -i'' "s:api_key:api_key \$(cat /home/ubuntu/MACKEREL_APIKEY):" /etc/fluent/fluent.conf
    sudo supervisorctl restart fluentd
SHELL
}

restart() {
    ssh "${HOST}" <<SHELL
    sudo supervisorctl restart b11d
SHELL
}

case $1 in
    setup) setup;;
    deploy) deploy;;
    seed_db) seed_db;;
    nginx) nginx;;
    supervisord) supervisord;;
    mysql) mysql;;
    mackerel) mackerel;;
    fluentd) fluentd;;
    restart) restart;;
esac
     
