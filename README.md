# trimui-brick-filebrowser.pak

A TrimUI Brick app wrapping [`filebrowser`](https://github.com/filebrowser/filebrowser/), an http file server.

## Requirements

- Docker (for building)

## Building

```shell
make build
```

## Installation

1. Mount your TrimUI Brick SD card.
2. Download the latest release from Github. It will be named `HTTP.Filebrowser.pak.zip`.
3. Copy the zip file to `/Tools/tg3040/HTTP Filebrowser.pak.zip`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/tg3040/HTTP Filebrowser.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your TrimUI Brick.

## Usage

> [!NOTE]
> The default credentials are:
>
> - `trimui:trimui`

### anonymous-access

By default, `filebrowser` requires a username and password for access control. To enable anonymous access, create a file named `anonymous-access`.

### daemon-mode

By default, `filebrowser` runs as a foreground process, terminating on app exit. To run `filebrowser` in daemon mode, create a file named `daemon-mode` in the pak folder. This will turn the app into a toggle for `filebrowser`.
