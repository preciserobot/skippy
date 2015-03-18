if [ -f "/home/vagrant/.provisioned_webserver" ]; then
  echo "[PROVISIONING] Already provisioned webserver..."
  exit 0
fi

# Install Apache
echo "[PROVISIONING] Installing apache2..."
sudo apt-get install -y apache2 # installs apache and some dependencies
sudo service apache2 restart # restarting for sanities' sake
echo "[PROVISIONING] Applying Apache vhost conf..."
sudo rm -f /etc/apache2/sites-available/default
sudo rm -f /etc/apache2/sites-enabled/000-default
sudo cp /home/vagrant/scripts/resources/default /etc/apache2/sites-available/
sudo ln -s /etc/apache2/sites-available/default /etc/apache2/sites-enabled/000-default
a2enmod rewrite # enable mod_rewrite
a2enmod actions # actions
sudo service apache2 restart

# Install PHP
echo "[PROVISIONING] Installing PHP..."
sudo apt-get install -y php5 php5-cli php5-common php5-curl php5-gd php5-mysql php5-dev # php install with common extensions
sudo service apache2 restart # restart apache so latest php config is picked up


echo "[PROVISIONING] Installing curl, make, openssl, vim..."
sudo apt-get install -y curl # curl
sudo apt-get install -y make # make is not installed by default believe it or not
sudo apt-get install -y openssl # openssl will allow https connections
sudo a2enmod ssl # enable ssl/https
sudo apt-get install -y unzip # unzip .zip files from cli
sudo apt-get install -y vim # Vim, since only the vim-tidy package is installed

echo "[PROVISIONING] Configuring web server..."
usermod -a -G vagrant www-data # adds vagrant user to www-data group

# set provisioning checkpoint
touch /home/vagrant/.provisioned_webserver
