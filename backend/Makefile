.PHONY: run build clean test

run:
	go run cmd/server/main.go

build:
	go build -o bin/server cmd/server/main.go

clean:
	rm -rf bin/ chat.db

test:
	go test -v ./...

deps:
	go mod download
	go mod tidy

docker-build:
	docker build -t chat-backend .

docker-run:
	docker run -p 8080:8080 chat-backend
