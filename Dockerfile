FROM public.ecr.aws/docker/library/node:18 AS deps

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

FROM public.ecr.aws/docker/library/node:18-slim AS runtime

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=deps /app/node_modules ./node_modules

# Copy js code and go binaries

COPY src/ ./src/

COPY bin/ ./bin/

RUN chmod +x ./bin/*

USER appuser

EXPOSE 3000
CMD ["node", "/app/src/000.js"]
