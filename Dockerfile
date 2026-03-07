# 1. Base ligera de Alpine 3.23
FROM alpine:3.23

# 2. Argumentos para el usuario (mapeo con UID 1000)
ARG USER=webdav
ARG UID=1000
ARG GID=1000

# 3. Instalación de paquetes
# Incluye nginx, el módulo WebDAV extendido y utilidades para contraseñas
RUN apk add --no-cache \
    nginx \
    nginx-mod-http-dav-ext \
    apache2-utils 

# 4. Crear usuario sin privilegios
RUN adduser -D -u ${UID} ${USER} 

# 5. Preparar estructura de directorios y permisos
# Se crean todas las rutas necesarias para logs, pids y temporales
RUN mkdir -p /data \
             /var/log/nginx \
             /var/lib/nginx/tmp \
             /run/nginx \
             /tmp/nginx_upload \
             /etc/nginx \
             /usr/local/bin \
             /usr/share/nginx/html && \
    # Ajuste de propiedad al usuario 1000 (webdav)
    chown -R ${UID}:${GID} /data \
                           /var/log/nginx \
                           /var/lib/nginx \
                           /run/nginx \
                           /tmp/nginx_upload \
                           /usr/share/nginx/html && \
    # Redirección de logs a stdout/stderr para recolectar con Podman
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# 6. Copiar archivos de configuración y scripts
# Asegúrate de tener estos archivos en el mismo directorio que el Dockerfile
COPY nginx.conf /etc/nginx/nginx.conf 
COPY auth.sh /usr/local/bin/auth 
COPY html/ /usr/share/nginx/html/ 

# 7. Ajustes finales de permisos y archivos de autenticación
RUN chmod +x /usr/local/bin/auth  && \
    touch /etc/nginx/.htpasswd  && \
    chown ${UID}:${GID} /etc/nginx/.htpasswd /usr/local/bin/auth && \
    chown -R ${UID}:${GID} /usr/share/nginx/html 

# 8. Metadatos y configuración de ejecución
USER ${USER}
EXPOSE 8080

# Comando de arranque (Nginx en primer plano)
CMD ["nginx", "-g", "daemon off;"]
