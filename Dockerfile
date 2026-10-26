# RMS PRIVATE test deployment ONLY. Cloud Run MUST require authentication.
FROM node:24-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
RUN npm run build

FROM node:24-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production RMS_DISABLE_SCHEDULERS=1
COPY --from=build /app /app
# Additional explicit acknowledgement; never set this for an unauthenticated service.
CMD ["sh", "-c", "test \"$RMS_PRIVATE_TEST_ACK\" = 1 || { echo 'Refusing startup: private-test acknowledgement missing'; exit 1; }; exec node --import tsx server.ts"]
