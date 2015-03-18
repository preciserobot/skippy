INSTALL_TARGET=${1}  # /usr/local/pipeline
PATH_FILE=${2}  # /home/vagrant/.bashrc
sudo mkdir -p $INSTALL_TARGET
sudo chmod 777 $INSTALL_TARGET
sed -i '$aINSTALL_TARGET=${INSTALL_TARGET}' $PATH_FILE
sed -i '$aPATH_FILE=${PATH_FILE}' $PATH_FILE

# VARIABLES
HOSTNAME="vagrant.molpath"
LOCALE_LANGUAGE="en"
LOCALE_CODESET="en.UTF-8"
TIMEZONE="Europe/London"

if [ -f "/home/vagrant/.provisioned_proxybox" ]; then
  echo "[PROVISIONING] Already provisioned proxybox..."
  exit 0
fi

echo "[PROVISIONING] importing dotfiles..."
cp /moldev/vagrant/dotfiles/.[!.]* /home/vagrant

echo "[PROVISIONING] Updating package manager lists..."
sudo apt-get update

echo "[PROVISIONING] Setting locale and timezone..."
sudo apt-get -y install language-pack-en
sudo locale-gen $LOCALE_LANGUAGE $LOCALE_CODESET
echo $TIMEZONE | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

echo "[PROVISIONING] Installing development tools and libraries..."
sudo apt-get -y install git
sudo apt-get -y install python-pip zlib1g-dev python2.7-dev  # python
#sudo apt-get -y install libpng-dev ncurses-dev
#sudo apt-get -y install libssl-dev openssl ssl-cert openssl-blacklist # SSL
#sudo apt-get -y install unzip htop
#sudo apt-get -y install tabix
#sudo apt-get -y install parallel

echo '[PROVISIONING] Installing python modules...'
sudo pip install python-dateutil
#sudo pip install pytabix
#sudo pip install XlsxWriter
#sudo pip install pysam
#sudo pip install Cython
#sudo pip install ruffus
#sudo pip install drmaa

echo '[PROVISIONING] Installing BaseSpace Python API...'
cd $INSTALL_TARGET \
  && git clone https://github.com/basespace/basespace-python-sdk.git \
  && cd $INSTALL_TARGET/basespace-python-sdk && git checkout 49570e1e05934b89c4b58ce3ba7e48e745b3c625 \
  && cd src && sudo python setup.py install

# set provisioning checkpoint
touch /home/vagrant/.provisioned_proxybox




