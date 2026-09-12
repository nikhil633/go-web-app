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