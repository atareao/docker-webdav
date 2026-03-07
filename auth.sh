#!/bin/sh

HTPASSWD_FILE="/etc/nginx/.htpasswd"

case "$1" in
    add)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Uso: webdav-auth add <usuario> <contraseña>"
            exit 1
        fi
        # -b para modo batch, -B para forzar cifrado bcrypt (más seguro)
        htpasswd -bB "$HTPASSWD_FILE" "$2" "$3"
        echo "Usuario '$2' añadido/actualizado."
        ;;
    del)
        if [ -z "$2" ]; then
            echo "Uso: webdav-auth del <usuario>"
            exit 1
        fi
        htpasswd -D "$HTPASSWD_FILE" "$2"
        echo "Usuario '$2' eliminado."
        ;;
    list)
        if [ ! -f "$HTPASSWD_FILE" ]; then
            echo "No hay usuarios configurados."
        else
            echo "Usuarios registrados:"
            cut -d: -f1 "$HTPASSWD_FILE"
        fi
        ;;
    *)
        echo "Gestor de usuarios WebDAV"
        echo "Comandos: add, del, list"
        exit 1
        ;;
esac
