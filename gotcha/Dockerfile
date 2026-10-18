# gotcha build: webapp + server in one image, served under a path prefix.
# nginx (:8000) serves the webapp and proxies /api, /socket and /public to the
# Node server (:3000). The gotcha ingress strips /g-bigcapital before the pod
# sees a request, but the webapp's asset URLs, router and API calls must carry
# the prefix — PUBLIC_URL bakes it in at build time.
# Build context: repo root.  Dockerfile: gotcha/Dockerfile

FROM node:18.16.0-alpine AS builder
WORKDIR /app
RUN npm install -g pnpm@9.0.5
RUN apk add --no-cache python3 build-base chromium
ENV PYTHON=/usr/bin/python3
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml lerna.json ./
COPY packages/server/package.json ./packages/server/
COPY packages/webapp/package.json ./packages/webapp/
COPY shared ./shared
RUN pnpm install --frozen-lockfile
COPY packages/server ./packages/server
COPY packages/webapp ./packages/webapp
ARG PUBLIC_URL=/g-bigcapital/
ENV PUBLIC_URL=$PUBLIC_URL
RUN pnpm run build:server --skip-nx-cache && pnpm run build:webapp

FROM node:18.16.0-alpine AS production
WORKDIR /app
RUN npm install -g pnpm@9.0.5
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
RUN apk add --no-cache python3 build-base nginx
ENV PYTHON=/usr/bin/python3
COPY --chown=nodejs:nodejs package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY --chown=nodejs:nodejs packages/server/package.json ./packages/server/
COPY --chown=nodejs:nodejs shared ./shared
COPY --chown=nodejs:nodejs .husky ./.husky
RUN pnpm add -D -w husky && \
    pnpm install --prod --frozen-lockfile && \
    pnpm remove -w husky && \
    apk del python3 build-base
COPY --from=builder --chown=nodejs:nodejs /app/packages/server/dist ./packages/server/dist
COPY --from=builder --chown=nodejs:nodejs /app/packages/server/src/i18n ./packages/server/dist/i18n
COPY --from=builder --chown=nodejs:nodejs /app/packages/server/public ./packages/server/public
COPY --from=builder --chown=nodejs:nodejs /app/packages/server/static ./packages/server/static
COPY --from=builder --chown=nodejs:nodejs /app/packages/server/src/database ./packages/server/src/database
COPY --from=builder --chown=nodejs:nodejs /app/shared ./shared
COPY --from=builder --chown=nodejs:nodejs /app/packages/webapp/dist ./webapp
COPY --chown=nodejs:nodejs gotcha/nginx.conf gotcha/start.sh ./gotcha/
RUN chmod +x ./gotcha/start.sh
ENV NODE_ENV=production
ENV NEW_RELIC_NO_CONFIG_FILE=true
ENV PORT=3000
USER nodejs
EXPOSE 8000
CMD ["/app/gotcha/start.sh"]
