# Servidor webdav partiendo de debian-testing

##  Clonar el repositorio

```
git clone https://github.com/uGeek/docker-nginx-webdav.git
```

y accedemos al interior de la carpeta:

```
cd docker-nginx-webdav
```

## Construir la imagen
```
docker build -t ugeek/webdav:arm .
```

## Ver el número de imagen:
```
docker images
```

## Montar el contenedor

USERNAME: webdav
PASSWORD: webdav
PUERTO: 80

--restart=unless-stopped: Iniciar cada vez que iniciemos el servidor


```
docker run --name webdav --restart=unless-stopped -p 80:80 -v $HOME/docker/webdav:/media -e USERNAME=webdav -e PASSWORD=webdav -d  <IMAGE>
```
