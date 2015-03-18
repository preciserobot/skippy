
if [ -f "/home/vagrant/.provisioned_gridengine_execd" ]; then
  echo "[PROVISIONING] Already provisioned gridengine_execd..."
  exit 0
fi

######
######
######

# set provisioning checkpoint
touch /home/vagrant/.provisioned_gridengine_execd
