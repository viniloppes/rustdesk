#!/bin/sh
# Entry point of the download container (nginx:alpine): fetches the client and serves it.
set -eu
apk add --no-cache curl >/dev/null

html=/usr/share/nginx/html
file="$APP_NAME.exe"
custom_url="https://github.com/$GITHUB_REPO/releases/download/custom-client/$file"
if curl -fsIL -o /dev/null "$custom_url"; then
  echo "Redirecting downloads to the custom client $custom_url"
  download_rule="return 302 $custom_url;"
else
  echo "No custom build in $GITHUB_REPO yet; serving the official client with the server in its file name"
  url=$(curl -fsSL https://api.github.com/repos/rustdesk/rustdesk/releases/latest \
    | sed -n 's/.*"browser_download_url": *"\([^"]*x86_64\.exe\)".*/\1/p' | head -n1)
  curl -fsSL -o "$html/client.exe" "$url"
  file="$APP_NAME-host=$RENDEZVOUS_SERVER,key=$RS_PUB_KEY,.exe"
  download_rule="default_type application/octet-stream;
    add_header Content-Disposition 'attachment; filename=\"$file\"';
    add_header Cache-Control no-store;
    try_files /client.exe =404;"
fi

cat > /etc/nginx/conf.d/default.conf <<NGX
server {
  listen 80;
  root $html;
  location = /download {
    $download_rule
  }
  location = /client.exe { return 301 /download; }
}
NGX

cat > "$html/index.html" <<HTML
<!doctype html>
<html lang="pt-br"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>$APP_NAME - Suporte remoto</title>
<style>
body{font-family:system-ui,sans-serif;max-width:560px;margin:56px auto;padding:0 16px;color:#1d1d1f;background:#fff}
a.b{display:inline-block;background:#0a66ff;color:#fff;padding:14px 24px;border-radius:10px;text-decoration:none;font-weight:600}
ol{line-height:1.8}code{background:#f0f0f0;padding:2px 6px;border-radius:4px;word-break:break-all}
@media (prefers-color-scheme:dark){body{background:#111;color:#eee}code{background:#222}}
</style></head><body>
<h1>$APP_NAME</h1>
<p><a class="b" href="/download">Baixar para Windows</a></p>
<ol><li>Abra o arquivo baixado (não precisa instalar).</li>
<li>Passe o <b>ID</b> e a <b>senha</b> mostrados na tela para quem vai te atender.</li></ol>
<hr><p><small>Outros sistemas: instale o RustDesk e em Configurações &gt; Rede &gt; Servidor ID/Relay informe<br>
Servidor ID: <code>$RENDEZVOUS_SERVER</code><br>Key: <code>$RS_PUB_KEY</code></small></p>
</body></html>
HTML

exec nginx -g 'daemon off;'
