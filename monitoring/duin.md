sudo docker logs diun 2>&1 | grep -iE 'updated|new image|update available'
sudo docker logs --since 168h diun
