FROM golang as build
WORKDIR /go

COPY http_server.go .
RUN pwd
RUN go build http_server.go
CMD ["./http_server"]




