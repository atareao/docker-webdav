# Servidor webdav partiendo de debian-testing

```
docker run --name webdavv --restart=unless-stopped -p 80:80 -v $HOME/docker/webdav:/media -e USERNAME=webdav -e PASSWORD=webdav -d  <IMAGE>
```
