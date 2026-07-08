#!/usr/bin/env bash
set -o pipefail
set -e

FAMF_STORE=${FAMF_STORE:-memory}

# Port the app is exposed on. Hosts like Render/Fly inject $PORT; default to 80 for local/docker use.
PORT="${PORT:-80}"

cd /app

# The Next.js production build is already baked into the image (see Dockerfile.allinone),
# so we must NOT rebuild at container start: it slows cold starts and can OOM small instances.

# Point Nginx at the runtime $PORT instead of the hardcoded 80.
sed -i -E "s/listen +80 default_server;/listen ${PORT} default_server;/" /etc/nginx/nginx.conf

# Nginx is the public entrypoint on $PORT and reverse-proxies to the internal
# services. `next start` also honors $PORT, so pin it to 3000 (the port
# nginx.conf proxies to) so it doesn't fight Nginx for the same port.
./Cold-Friendly-Feud --game_store "$FAMF_STORE" &
nginx -g 'daemon off;' &
PORT=3000 npm run start &

wait -n
