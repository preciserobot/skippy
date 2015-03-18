if [ -f "/home/vagrant/.provisioned_gridengine_master" ]; then
  echo "[PROVISIONING] Already provisioned gridengine_master..."
  exit 0
fi


echo "[PROVISIONING] Installing GridEngine (postfix, OGS, DRMAA)..."
# unattended postfix install
echo "postfix                 postfix/mailname         string  ${HOSTNAME}" | sudo debconf-set-selections
echo "postfix                 postfix/main_mailer_type select  Internet Site" | sudo debconf-set-selections
sudo apt-get install -y postfix
sudo service postfix reload
# unattended gridengine install
echo "gridengine-master       shared/gridenginemaster  string  ${HOSTNAME}" | sudo debconf-set-selections
echo "gridengine-master       shared/gridenginecell    string  default" | sudo debconf-set-selections
echo "gridengine-master       shared/gridengineconfig  boolean true" | sudo debconf-set-selections
echo "gridengine-common       shared/gridenginemaster  string  ${HOSTNAME}" | sudo debconf-set-selections
echo "gridengine-common       shared/gridenginecell    string  default" | sudo debconf-set-selections
echo "gridengine-common       shared/gridengineconfig  boolean true" | sudo debconf-set-selections
echo "gridengine-client       shared/gridenginemaster  string  ${HOSTNAME}" | sudo debconf-set-selections
echo "gridengine-client       shared/gridenginecell    string  default" | sudo debconf-set-selections
echo "gridengine-client       shared/gridengineconfig  boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gridengine-common gridengine-client gridengine-master gridengine-qmon
sudo -u sgeadmin /usr/share/gridengine/scripts/init_cluster /var/lib/gridengine default /var/spool/gridengine/spooldb sgeadmin
sudo service gridengine-master restart
sudo apt-get install -y sudo suxfonts-base xfonts-100dpi xfonts-75dpi


## drmaa


# set provisioning checkpoint
touch /home/vagrant/.provisioned_gridengine_master