# minui-http-filebrowser.pak

A MinUI app wrapping [`filebrowser`](https://github.com/filebrowser/filebrowser/), an http file server.

## Requirements

This pak is designed and tested on the following MinUI Platforms and devices:

- `tg5040`: Trimui Brick (formerly `tg3040`), Trimui Smart Pro
- `rg35xxplus`: RG-35XX Plus, RG-34XX, RG-35XX H, RG-35XX SP

Use the correct platform for your device.

## Installation

1. Mount your MinUI SD card.
2. Download the latest release from Github. It will be named `HTTP.Filebrowser.pak.zip`.
3. Copy the zip file to `/Tools/$PLATFORM/HTTP Filebrowser.pak.zip`. Please ensure the new zip file name is `HTTP Filebrowser.pak.zip`, without a dot (`.`) between the words `HTTP` and `Filebrowser`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/$PLATFORM/HTTP Filebrowser.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your MinUI device.

## Usage

> [!IMPORTANT]
> If the zip file was not extracted correctly, the pak may show up under `Tools > HTTP`. Rename the folder to `HTTP Filebrowser.pak` to fix this.

Browse to `Tools > HTTP Filebrowser` and press `A` to turn on the HTTP Filebrowser

This pak runs on port `80` (HTTP).

The default credentials are:

- `trimui:trimui`

### Debug Logging

Debug logs are written to the`$SDCARD_PATH/.userdata/$PLATFORM/logs/` folder.

### Configuration

#### anonymous-access

By default, `filebrowser` requires a username and password for access control. To enable anonymous access, create a file named `anonymous-access` in the `$SDCARD_PATH/.userdata/$PLATFORM/HTTP Filebrowser` folder.
