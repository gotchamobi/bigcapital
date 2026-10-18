#!/bin/sh
# Migrations are idempotent (knex migrate:latest), so every boot runs them —
# the compose stack's separate migration job has no equivalent here.
set -e
cd /app/packages/server
node dist/cli.js system:migrate:latest
node dist/cli.js tenants:migrate:latest
nginx -e /dev/stderr -c /app/gotcha/nginx.conf
cd /app
exec node packages/server/dist/main.js
