set shell := ["fish", "-c"]

user    := "atareao"
name    := "nginx-webdav"
version := "0.1.0"

# Muestra ayuda
default:
    @just --list

# --- MÉTODO 1: DOCKERFILE ---
# Construye usando el estándar declarativo
build-docker:
    @echo "### Construyendo con Dockerfile (Standard) ###"
    buildah bud -t {{user}}/{{name}}:docker .

# --- MÉTODO 2: SCRIPT FISH ---
# Construye usando el método artesanal/imperativo
build-script:
    @echo "### Construyendo con Script de Fish (Artesano) ###"
    chmod +x build-webdav.fish
    buildah unshare ./build-webdav.fish

# --- COMPARATIVA DE PESO ---
# Muestra cuánto ocupa cada una para el veredicto del episodio
compare:
    @echo "--- RESULTADOS DE TAMAÑO ---"
    @echo "IMAGEN           |  TAMAÑO"
    @echo "-----------------|----------"
    @buildah images --format "{{"{{.Name}}:{{.Tag}} | {{.Size}}"}}" | grep "{{name}}"

# --- LIMPIEZA ---
# Borra ambas imágenes para empezar de cero
clean:
    -buildah rmi {{user}}/{{name}}:docker
    -buildah rmi {{user}}/{{name}}:latest

# --- FLUJO COMPLETO PARA EL VÍDEO ---
# Ejecuta todo el proceso: construye ambos y compara
demo: build-docker build-script compare

# Lanza el contenedor WebDAV para pruebas
run:
    @echo "Iniciando WebDAV en http://localhost:8080"
    @mkdir -p ./test-data
    podman run --rm -it -p 8080:8080 \
               -v ./test-data:/data:Z \
               localhost/{{user}}/{{name}}:latest

# Lanza el WebDAV en segundo plano (Persistent mode)
up:
    @echo "Levantando WebDAV en segundo plano..."
    @mkdir -p ./test-data
    podman run -d \
        --name {{name}} \
        --init \
        --userns=keep-id \
        -p 8080:8080 \
        -v "$PWD/test-data:/data:Z" \
        localhost/{{user}}/{{name}}:latest
    @echo "¡Listo! Accede en http://localhost:8080"

# Detiene y borra el contenedor
down:
    @echo "Deteniendo WebDAV..."
    -podman stop {{name}}
    -podman rm {{name}}

# Muestra los logs (para ver qué pasa dentro)
logs:
    podman logs -f {{name}}
