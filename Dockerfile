# FROM golang:1.26-alpine AS base

# WORKDIR /app

# COPY go.mod .

# RUN go mod download

# COPY . .

# RUN go build -o main .

# FROM gcr.io/distroless/base

# COPY --from=base /app/main .

# COPY --from=base /app/static ./static

# EXPOSE 8081

# CMD [ "./main" ]


# ==========================================
# BUILD BASE
# ==========================================
FROM golang:1.26 AS base

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .


# ==========================================
# DEVELOPMENT
# ==========================================
FROM base AS dev

RUN apt-get update && apt-get install -y \
    curl \
    git \
    procps \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN go install github.com/go-delve/delve/cmd/dlv@latest

# Debug-friendly build
RUN go build -gcflags="all=-N -l" -o main .

EXPOSE 8081 40000

CMD ["./main"]


# ==========================================
# PRODUCTION BUILD
# ==========================================
FROM base AS production-build

RUN go build -o main .


# ==========================================
# PRODUCTION RUNTIME
# ==========================================
FROM gcr.io/distroless/base-debian12 AS prod

WORKDIR /app

COPY --from=production-build /app/main .
COPY --from=base /app/static ./static

EXPOSE 8081

CMD ["./main"]



# /*
# # =========================================================
# # STAGE 1 — Dependencies Cache
# # =========================================================
# FROM golang:1.22-alpine AS deps

# WORKDIR /app

# # Install required packages
# RUN apk add --no-cache git ca-certificates tzdata

# # Copy dependency files first for better caching
# COPY go.mod go.sum ./

# # Download dependencies
# RUN go mod download



# # =========================================================
# # STAGE 2 — Development Environment
# # =========================================================
# FROM deps AS dev

# WORKDIR /app

# # Install hot reload tool
# RUN go install github.com/air-verse/air@latest

# COPY . .

# EXPOSE 8080

# CMD ["air"]



# # =========================================================
# # STAGE 3 — Build Stage
# # =========================================================
# FROM deps AS builder

# WORKDIR /app

# COPY . .

# # Build arguments
# ARG VERSION=1.0.0
# ARG COMMIT=unknown
# ARG BUILD_TIME=unknown

# # Disable CGO for static binary
# ENV CGO_ENABLED=0
# ENV GOOS=linux
# ENV GOARCH=amd64

# # Build optimized binary
# RUN go build \
#     -ldflags="-s -w \
#     -X main.version=${VERSION} \
#     -X main.commit=${COMMIT} \
#     -X main.buildTime=${BUILD_TIME}" \
#     -o main .



# # =========================================================
# # STAGE 4 — Production Runtime
# # =========================================================
# FROM gcr.io/distroless/static-debian12 AS production

# # Labels for metadata
# LABEL maintainer="devops-team@company.com"
# LABEL description="Production Go Application"
# LABEL version="1.0.0"

# WORKDIR /app

# # Copy required runtime files
# COPY --from=builder /app/main .
# COPY --from=builder /app/static ./static
# COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# # Non-root user for security
# USER nonroot:nonroot

# # Environment variables
# ENV PORT=8080
# ENV APP_ENV=production

# # Expose application port
# EXPOSE 8080

# # Healthcheck
# HEALTHCHECK --interval=30s \
#              --timeout=5s \
#              --start-period=10s \
#              --retries=3 \
# CMD ["/app/main", "healthcheck"]

# # Start application
# ENTRYPOINT ["/app/main"]
# */