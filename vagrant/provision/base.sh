
# VARIABLES
HOSTNAME="vagrant.molpath"
LOCALE_LANGUAGE="en"
LOCALE_CODESET="en.UTF-8"
TIMEZONE="Europe/London"

if [ -f "/home/vagrant/.provisioned_base" ]; then
  echo "[PROVISIONING] Already provisioned base..."
  exit 0
fi

echo "[PROVISIONING] importing dotfiles..."
cp /moldev/vagrant/dotfiles/.[!.]* /home/vagrant

echo "[PROVISIONING] Setting locale and timezone..."
sudo apt-get -y install language-pack-en
sudo locale-gen $LOCALE_LANGUAGE $LOCALE_CODESET
echo $TIMEZONE | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

echo "[PROVISIONING] Updating package manager lists..."
sudo apt-get update

echo "[PROVISIONING] Installing development tools and libraries..."
sudo apt-get -y install git
sudo apt-get -y install python-pip zlib1g-dev python2.7-dev  # python
sudo apt-get -y install libpng-dev ncurses-dev
sudo apt-get -y install libssl-dev openssl ssl-cert openssl-blacklist # SSL
sudo apt-get -y install unzip htop vim
sudo apt-get -y install tabix
sudo apt-get -y install parallel
sudo apt-get -y install cmake  # build tools
echo "[PROVISIONING] Installing postfix, mailutils..."
echo postfix postfix/mailname string $HOSTNAME | debconf-set-selections
echo postfix postfix/main_mailer_type string 'Internet Site' | debconf-set-selections
sudo apt-get install -y postfix
sudo apt-get -y install mailutils  # mailx - needs to be installed manually
service postfix reload

# java (openJDK-7)
sudo apt-get -y install openjdk-7-jre openjdk-7-jdk
sed  -i '$aJAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' $PATH_FILE

echo "[PROVISIONING] Installing database clients (mySQL, SQLite)..."
sudo apt-get install -y mysql-client-5.5 mysql-client-core-5.5 libmysqlclient-dev sqlite

echo "[PROVISIONING] Installing docker..."
curl -s https://get.docker.io/ubuntu/ | sudo sh

# set provisioning checkpoint
touch /home/vagrant/.provisioned_base
