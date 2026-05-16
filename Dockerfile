# syntax=docker/dockerfile:1

FROM node:20-alpine AS runtime

ENV NODE_ENV=production
WORKDIR /usr/src/app

# Install dependencies first to maximize Docker layer caching.
COPY src/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy application source after dependencies.
COPY src/ ./

# Run as the non-root user provided by the official Node image.
USER node

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:8080/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["npm", "start"]
