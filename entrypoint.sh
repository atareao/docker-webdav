#!/bin/bash

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]
then
	htpasswd -bc /etc/nginx/htpasswd $USERNAME $PASSWORD
	echo Done.
else
    echo Using no auth.
	sed -i 's%auth_basic "Restricted";% %g' /etc/nginx/conf.d/default.conf
	sed -i 's%auth_basic_user_file htpasswd;% %g' /etc/nginx/conf.d/default.conf
fi
mediaowner=$(ls -ld /media | awk '{print $3}')
echo "Current /media owner is $mediaowner"
if [ "$mediaowner" != "www-data" ]
then
    chown -R www-data:www-data /media
fi
