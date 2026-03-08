#!/usr/bin/fish

set user webdav
set name "nginx-webdav"
set image_base "alpine:3.23"

echo "--- Construyendo imagen NO-ROOT de $name ---"

set container (buildah from $image_base)

# FUNCIÓN DE LIMPIEZA: Se ejecuta si el script falla o termina
function cleanup --on-event fish_exit
    if set -q mountpoint
        echo "--- Desmontando contenedor de forma segura ---"
        buildah unmount $container 2>/dev/null
    end
end

# 1. Instalar paquetes
buildah run $container -- apk add --no-cache \
        nginx \
        nginx-mod-http-dav-ext \
        apache2-utils


# 2. Crear usuario '$user' (UID 1000 para que mapee con tu usuario de Arch)
buildah run $container -- adduser -D -u 1000 $user

# 3. Montar para configurar
set mountpoint (buildah mount $container)

# 4. Crear y asegurar directorios para el usuario '$user'
# Necesitamos que Nginx pueda escribir logs, pids y temporales sin ser root
mkdir -p $mountpoint/data \
         $mountpoint/var/log/nginx \
         $mountpoint/var/lib/nginx/tmp \
         $mountpoint/run/nginx \
         $mountpoint/tmp/nginx_upload \
         $mountpoint/etc/nginx \
         $mountopoint/usr/local/bin \
         $mountopoint/usr/share/nginx/html

# CAMBIO CLAVE: Todo pertenece al usuario 1000
chown -R 1000:1000 $mountpoint/data \
                   $mountpoint/var/log/nginx \
                   $mountpoint/var/lib/nginx \
                   $mountpoint/run/nginx \
                   $mountpoint/tmp/nginx_upload \
                   $mountopoint/usr/share/nginx/html

# Enlazamos logs a la salida del contenedor
ln -sf /dev/stdout $mountpoint/var/log/nginx/access.log
ln -sf /dev/stderr $mountpoint/var/log/nginx/error.log

# 5. Copiar configuración
cp nginx.conf $mountpoint/etc/nginx/nginx.conf
cp auth.sh $mountpoint/usr/local/bin/auth
cp -r html $mountpoint/usr/share/nginx/html
chmod +x $mountpoint/usr/local/bin/auth
touch $mountpoint/etc/nginx/.htpasswd
chown 1000:1000 $mountpoint/etc/nginx/.htpasswd $mountpoint/usr/local/bin/auth
chown -R 1000:1000 $mountpoint/usr/share/nginx/html

# 6. Metadatos: Cambiamos el usuario de ejecución
buildah config --user $user $container
buildah config --port 8080 $container
buildah config --cmd '["nginx", "-g", "daemon off;"]' $container

buildah unmount $container
set -e mountpoint # Eliminamos la variable para evitar que el cleanup actúe dos veces

buildah commit --rm --squash $container atareao/$name:latest
