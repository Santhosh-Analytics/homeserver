sudo apt install -y restic
export RESTIC_REPOSITORY=b2:san-homeserver-backup:homeserver
export B2_ACCOUNT_ID=NEW_KEY_ID
export B2_ACCOUNT_KEY=NEW_APP_KEY
restic snapshots                         # asks for your password
restic restore latest --target /


#A monthly health check
sudo bash -c 'source /root/.config/restic/env && restic check --read-data-subset=5%'
