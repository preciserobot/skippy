
# VARIABLES
LOCALE_LANGUAGE="en"
LOCALE_CODESET="en.UTF-8"
TIMEZONE="Europe/London"

if [ -f "/home/vagrant/.provisioned_docker" ]; then
  echo "[PROVISIONING] Already provisioned docker..."
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

echo "[PROVISIONING] Installing docker..."
apt-get -y install docker.io
ln -sf /usr/bin/docker.io /usr/local/bin/docker
sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
update-rc.d docker.io defaults

#echo "[PROVISIONING] Installing docker..."
#curl -s https://get.docker.io/ubuntu/ | sudo sh

# set provisioning checkpoint
touch /home/vagrant/.provisioned_docker
