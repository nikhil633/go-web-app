FROM golang:1.26 AS base

WORKDIR /app

COPY go.mod .

RUN go mod download

COPY . .

RUN go build -o main .

EXPOSE 8081

CMD ["./main"]