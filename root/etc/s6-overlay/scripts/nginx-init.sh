#!/command/with-contenv bash

set -euo pipefail

source /etc/hluser

# make our folders
echo "================== make /config =========="
mkdir -p \
	/config/{nginx/site-confs,www,log/nginx,keys,log/php} \
	/run \
	/var/lib/nginx/tmp/client_body \
	/var/tmp/nginx

# copy config files
if [[ ! -f /config/nginx/nginx.conf ]]; then
	echo "copy /defaults/nginx.conf to /config/nginx/nginx.conf"
	cp /defaults/nginx.conf /config/nginx/nginx.conf
	ls -al /config/nginx/
	sed -i -e "s/HL_USER_USERNAME/$HL_USER_USERNAME/g" /config/nginx/nginx.conf
fi
if [[ ! -f /config/nginx/site-confs/default ]]; then
	echo "copy /defaults/default to /config/nginx/site-confs/default"
	cp /defaults/default /config/nginx/site-confs/default
	ls -al /config/nginx/site-confs/
fi

# permissions
chown -R "$HL_USER_USERNAME:$HL_USER_GROUPNAME" \
	/config \
	/run \
	/var/lib/nginx \
	/var/tmp/nginx 
chmod -R g+w \
	/config/{nginx,www}
chmod -R 644 /etc/logrotate.d

# permissions /opt/www
chown -R "$HL_USER_USERNAME:$HL_USER_GROUPNAME" /opt/www

# create /opt/www 
[ -d /opt/www ] || mkdir -p /opt/www

if [ -n "$HL_USER_USERNAME" ]; then
	chown -R "$HL_USER_USERNAME:$HL_USER_GROUPNAME" /opt/www
fi

if [ -n "${HL_USER_PASSWORD:-}" ]; then
	printf "%s:%s\n" "$HL_USER_USERNAME" "$(openssl passwd -apr1 "$HL_USER_PASSWORD")" > /opt/www/.htpasswd
fi

