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

./Cold-Friendly-Feud --game_store "$FAMF_STORE" &
nginx -g 'daemon off;' &
npm run start &

wait -n
