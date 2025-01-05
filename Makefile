TAG ?= v2.31.2
BUILD_DATE := "$(shell date -u +%FT%TZ)"

clean:
	rm -f bin/evtest || true
	rm -f bin/filebrowser || true

build: bin/evtest bin/filebrowser

bin/evtest:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.evtest --progress plain -t app/evtest:$(TAG) .
	docker container create --name extract app/evtest:$(TAG)
	docker container cp extract:/go/src/github.com/freedesktop/evtest/evtest bin/evtest
	docker container rm extract
	chmod +x bin/evtest

bin/filebrowser:
	curl -sL https://github.com/filebrowser/filebrowser/releases/download/$(TAG)/linux-arm64-filebrowser.tar.gz | tar -xz -C bin