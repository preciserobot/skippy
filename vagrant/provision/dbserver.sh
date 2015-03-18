
if [ -f "/home/vagrant/.provisioned_dbserver" ]; then
  echo "[PROVISIONING] Already provisioned dbserver..."
  exit 0
fi

MYSQL_PASS="molpath"  # CAUTION: ONLY FOR DEVELOPMENT
echo "[PROVISIONING] Installing database server (mySQL)..."
echo mysql-server mysql-server/root_password select $MYSQL_PASS | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again select $MYSQL_PASS | sudo debconf-set-selections
sudo apt-get install -y mysql-server-5.5 # install mysql server and client
sudo service mysql restart # restarting for sanities' sake
sudo apt-get -y install sqlite


# setup mysql database access
echo "CREATE USER 'vagrant'@'localhost' IDENTIFIED BY '${MYSQL_PASS}'" | mysql -uroot -p$MYSQL_PASS
echo "CREATE DATABASE molpath" | mysql -uroot -p$MYSQL_PASS
echo "GRANT ALL PRIVILEGES ON molpath.* TO 'vagrant'@'%' IDENTIFIED BY '${MYSQL_PASS}'" | mysql -uroot -p$MYSQL_PASS
echo "flush privileges" | mysql -uroot -p$MYSQL_PASS
if [ -f /moldev/vagrant/provision/dbsetup.sql ]; then
    mysql -uroot -p$MYSQL_PASS molpath < /moldev/vagrant/provision/dbsetup.sql
fi

# enable remote access
sudo sed -i 's/^skip-external-locking/;skip-external-locking/' /etc/mysql/my.cnf
sudo sed -i 's/^bind-address/;bind-address/' /etc/mysql/my.cnf
sudo service mysql restart

# set provisioning checkpoint
touch /home/vagrant/.provisioned_dbserver
