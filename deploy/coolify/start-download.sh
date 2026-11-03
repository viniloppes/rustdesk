#!/bin/sh
set -eu
export LC_ALL=C

host="${RUSTDESK_HOST:?}"
filename="${WINDOWS_FILENAME:?}"
product_name="${WINDOWS_PRODUCT_NAME:?}"
key="$(cat /public/key)"

if ! printf '%s' "$host" | grep -zEq '^([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$' ||
   [ "${#host}" -gt 63 ]; then
  echo 'RUSTDESK_HOST deve ser um domínio de até 63 caracteres, sem protocolo ou porta.' >&2
  exit 1
fi

if ! printf '%s' "$filename" | grep -zEq '^[A-Za-z0-9][A-Za-z0-9_-]{0,79}\.exe$' ||
   ! printf '%s' "$product_name" | grep -zEq '^[A-Za-z0-9][A-Za-z0-9 _-]{0,79}$'; then
  echo 'Confira WINDOWS_FILENAME e WINDOWS_PRODUCT_NAME no README.' >&2
  exit 1
fi

if ! printf '%s' "$key" | grep -zEq '^[A-Za-z0-9+/]{43}=$' ||
   [ "${#key}" -ne 44 ]; then
  echo 'Chave pública inválida. Confira os logs de hbbs e public-key.' >&2
  exit 1
fi

# The Windows client expects reversed URL-safe Base64. A raw key can contain '/'.
server_config="$(printf '{"host":"%s","key":"%s"}' "$host" "$key" |
  base64 -w0 | tr -- '+/' '-_' | tr -d '=' | rev)"

mkdir -p /srv/download
makensis -V2 -DPRODUCT_NAME="$product_name" -DSERVER_CONFIG="$server_config" \
  -DCLIENT_PATH=/app/rustdesk.exe \
  -DOUTPUT_PATH=/srv/download/client.exe /app/launcher.nsi

cat > /etc/nginx/conf.d/download.conf <<CONFIG
server {
    listen 8080;
    server_name _;

    location = /windows {
        alias /srv/download/client.exe;
        default_type application/octet-stream;
        add_header Content-Disposition 'attachment; filename="$filename"';
        add_header Cache-Control "no-store";
    }

    location = /windows/source {
        return 302 https://github.com/rustdesk/rustdesk/tree/1.5.1;
    }
}
CONFIG

exec nginx -g 'daemon off;'
