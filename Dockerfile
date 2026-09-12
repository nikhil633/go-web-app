FROM golang:1.26-alpine AS base

WORKDIR /app

COPY go.mod .

RUN go mod download

COPY . .

RUN go build -o main .

EXPOSE 8081

CMD ["./main"]