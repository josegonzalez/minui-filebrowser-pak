PAK_NAME := $(shell jq -r .label config.json)

ARCHITECTURES := arm arm64
PLATFORMS := rg35xxplus tg5040

FILEBROWSER_VERSION ?= v2.31.2
JQ_VERSION ?= 1.7.1
MINUI_LIST_VERSION := 0.11.3
MINUI_PRESENTER_VERSION := 0.7.0

clean:
	rm -f bin/*/filebrowser || true
	rm -f bin/*/jq || true
	rm -f bin/*/minui-list || true
	rm -f bin/*/minui-presenter || true

build: $(foreach platform,$(PLATFORMS),bin/$(platform)/minui-list bin/$(platform)/minui-presenter) $(foreach arch,$(ARCHITECTURES),bin/$(arch)/filebrowser bin/$(arch)/jq)

bin/arm/filebrowser:
	mkdir -p bin/arm
	curl -sL https://github.com/filebrowser/filebrowser/releases/download/$(FILEBROWSER_VERSION)/linux-armv7-filebrowser.tar.gz | tar -xz -C bin/arm
	chmod +x bin/arm/filebrowser
	rm -f bin/arm/CHANGELOG.md bin/arm/README.md
	mv bin/arm/LICENSE bin/arm/filebrowser.LICENSE

bin/arm64/filebrowser:
	mkdir -p bin/arm64
	curl -sL https://github.com/filebrowser/filebrowser/releases/download/$(FILEBROWSER_VERSION)/linux-arm64-filebrowser.tar.gz | tar -xz -C bin/arm64
	chmod +x bin/arm64/filebrowser
	rm -f bin/arm64/CHANGELOG.md bin/arm64/README.md
	mv bin/arm64/LICENSE bin/arm64/filebrowser.LICENSE

bin/arm/jq:
	mkdir -p bin/arm
	curl -f -o bin/arm/jq -sSL https://github.com/jqlang/jq/releases/download/jq-$(JQ_VERSION)/jq-linux-armhf
	curl -sSL -o bin/arm/jq.LICENSE "https://raw.githubusercontent.com/jqlang/jq/refs/heads/$(JQ_VERSION)/COPYING"

bin/arm64/jq:
	mkdir -p bin/arm64
	curl -f -o bin/arm64/jq -sSL https://github.com/jqlang/jq/releases/download/jq-$(JQ_VERSION)/jq-linux-arm64
	curl -sSL -o bin/arm64/jq.LICENSE "https://raw.githubusercontent.com/jqlang/jq/refs/heads/$(JQ_VERSION)/COPYING"

bin/%/minui-list:
	mkdir -p bin/$*
	curl -f -o bin/$*/minui-list -sSL https://github.com/josegonzalez/minui-list/releases/download/$(MINUI_LIST_VERSION)/minui-list-$*
	chmod +x bin/$*/minui-list

bin/%/minui-presenter:
	mkdir -p bin/$*
	curl -f -o bin/$*/minui-presenter -sSL https://github.com/josegonzalez/minui-presenter/releases/download/$(MINUI_PRESENTER_VERSION)/minui-presenter-$*
	chmod +x bin/$*/minui-presenter

release: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist
