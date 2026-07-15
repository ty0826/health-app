FROM node:22.22.0-slim AS build

WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@11.13.0 --activate

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
ARG TARO_APP_API_BASE_URL=/api
ENV TARO_APP_API_BASE_URL=${TARO_APP_API_BASE_URL}
RUN pnpm run build:h5

FROM nginxinc/nginx-unprivileged:1.27.4-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /workspace/dist /usr/share/nginx/html

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1
