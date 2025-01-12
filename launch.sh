#!/bin/sh
echo "$0" "$@"
progdir="$(dirname "$0")"
cd "$progdir" || exit 1
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$progdir/lib"
echo 1 >/tmp/stay_awake
trap "rm -f /tmp/stay_awake" EXIT INT TERM HUP QUIT
BUTTON_LOG="$progdir/log/buttons.log"

SERVICE_NAME="filebrowser"
HUMAN_READABLE_NAME="HTTP Filebrowser Server"
SUPPORTS_DAEMON_MODE=1
service_on() {
    cd /mnt/SDCARD/ || exit
    if [ -f "$progdir/log/service.log" ]; then
        mv "$progdir/log/service.log" "$progdir/log/service.log.old"
    fi

    chmod +x "$progdir/bin/filebrowser"
    touch "$progdir/filebrowser.db"
    if [ -f "$progdir/anonymous-access" ]; then
        "$progdir/bin/filebrowser" config set --auth.method=json -d "$progdir/filebrowser.db"
    else
        "$progdir/bin/filebrowser" config set --auth.method=noauth -d "$progdir/filebrowser.db"
    fi

    # trimui password hash
    trimui_password_hash='$2y$10$RFnHktgHmBR3keGIof.AbeStAoeksLxqFs4fSQqrkANLvIANCEioW'

    ("$progdir/bin/filebrowser" -p 80 -a 0.0.0.0 -r /mnt/SDCARD -d "$progdir/filebrowser.db" -l "$progdir/log/service.log" --username trimui --password "$trimui_password_hash" &) &
}

service_off() {
    killall "$SERVICE_NAME"
}

show_message() {
    message="$1"
    seconds="$2"

    if [ -z "$seconds" ]; then
        seconds="forever"
    fi

    killall sdl2imgshow
    echo "$message"
    if [ "$seconds" = "forever" ]; then
        "$progdir/bin/sdl2imgshow" \
            -i "$progdir/res/background.png" \
            -f "$progdir/res/fonts/BPreplayBold.otf" \
            -s 27 \
            -c "220,220,220" \
            -q \
            -t "$message" &
    else
        "$progdir/bin/sdl2imgshow" \
            -i "$progdir/res/background.png" \
            -f "$progdir/res/fonts/BPreplayBold.otf" \
            -s 27 \
            -c "220,220,220" \
            -q \
            -t "$message"
        sleep "$seconds"
    fi
}

monitor_buttons() {
    chmod +x "$progdir/bin/evtest"
    for dev in /dev/input/event*; do
        [ -e "$dev" ] || continue
        "$progdir/bin/evtest" "$dev" 2>&1 | while read -r line; do
            if echo "$line" | grep -q "code 17 (ABS_HAT0Y).*value -1"; then
                echo "D_PAD_UP detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 17 (ABS_HAT0Y).*value 1"; then
                echo "D_PAD_DOWN detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 16 (ABS_HAT0X).*value 1"; then
                echo "D_PAD_RIGHT detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 16 (ABS_HAT0X).*value -1"; then
                echo "D_PAD_LEFT detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 308 (BTN_WEST).*value 1"; then
                echo "BUTTON_X detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 305 (BTN_EAST).*value 1"; then
                echo "BUTTON_A detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 304 (BTN_SOUTH).*value 1"; then
                echo "BUTTON_B detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 307 (BTN_NORTH).*value 1"; then
                echo "BUTTON_Y detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 317 (BTN_THUMBL).*value 1"; then
                echo "HOTKEY_1 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 318 (BTN_THUMBR).*value 1"; then
                echo "HOTKEY_2 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 310 (BTN_TL).*value 1"; then
                echo "L1 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 311 (BTN_TR).*value 1"; then
                echo "R1 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 2 (ABS_Z).*value 255"; then
                echo "L2 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 5 (ABS_RZ).*value 255"; then
                echo "R2 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 316 (BTN_MODE).*value 1"; then
                echo "MENU detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 314 (BTN_SELECT).*value 1"; then
                echo "SELECT detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 315 (BTN_START).*value 1"; then
                echo "START detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 115 (KEY_VOLUMEUP).*value 1"; then
                echo "VOLUME_UP detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 114 (KEY_VOLUMEDOWN).*value 1"; then
                echo "VOLUME_DOWN detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 116 (KEY_POWER).*value 1"; then
                echo "POWER detected" >>"$BUTTON_LOG"
            fi
        done &
    done
}

wait_for_button() {
    button="$1"
    while true; do
        if grep -q "$button" "$BUTTON_LOG"; then
            break
        fi
        sleep 0.1
    done
}

wait_for_service() {
    max_counter="$1"
    counter=0

    while ! pgrep "$SERVICE_NAME" >/dev/null 2>&1; do
        counter=$((counter + 1))
        if [ "$counter" -gt "$max_counter" ]; then
            return 1
        fi
        sleep 1
    done
}

main_daemonize() {
    echo "Toggling $SERVICE_NAME..."
    if pgrep "$SERVICE_NAME"; then
        show_message "Disabling the $HUMAN_READABLE_NAME" 2
        service_off
    else
        show_message "Enabling the $HUMAN_READABLE_NAME" 2
        service_on

        if ! wait_for_service 10; then
            show_message "Failed to start $HUMAN_READABLE_NAME" 2
            return 1
        fi
    fi

    show_message "Done" 1
}

main_process() {
    if pgrep "$SERVICE_NAME"; then
        show_message "Disabling the $HUMAN_READABLE_NAME" 2
        service_off
    fi

    show_message "Starting $HUMAN_READABLE_NAME" 2
    service_on
    sleep 1

    echo "Waiting for $HUMAN_READABLE_NAME to be running"
    if ! wait_for_service 10; then
        show_message "Failed to start $HUMAN_READABLE_NAME" 2
        return 1
    fi

    if [ -f "$progdir/log/buttons.log" ]; then
        mv "$progdir/log/buttons.log" "$progdir/log/buttons.log.old"
    fi
    show_message "Press B to exit"
    monitor_buttons

    wait_for_button "BUTTON_B"
    show_message "Stopping $HUMAN_READABLE_NAME"
    service_off
    killall evtest
    sync
    sleep 1
    show_message "Done" 1
}

main() {
    if [ "$SUPPORTS_DAEMON_MODE" -eq 0 ]; then
        service_on
        return $?
    fi

    if [ -f "$progdir/daemon-mode" ]; then
        main_daemonize
    else
        main_process
    fi
    killall sdl2imgshow
}

mkdir -p "$progdir/log"
if [ -f "$progdir/log/launch.log" ]; then
    mv "$progdir/log/launch.log" "$progdir/log/launch.log.old"
fi

main "$@" >"$progdir/log/launch.log" 2>&1
