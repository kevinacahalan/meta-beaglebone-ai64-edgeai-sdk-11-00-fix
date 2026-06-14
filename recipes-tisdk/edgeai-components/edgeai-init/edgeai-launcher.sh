#!/bin/sh

ENABLE_GUI=1
EDGEAI_INIT_SCRIPT=/opt/edgeai-gst-apps/init_script.sh
EDGEAI_GUI_APP=/usr/bin/edgeai-gui-app
PIDFILE=/var/run/edgeai-gui-app.pid
EDGEAI_WALLPAPER_UPDATE=/opt/edgeai-gst-apps/scripts/setup_wallpaper.sh

wait_for_psplash_exit() {
    i=0
    while pidof psplash >/dev/null 2>&1 && [ "$i" -lt 50 ]; do
        sleep 0.2
        i=$((i + 1))
    done

    if pidof psplash >/dev/null 2>&1; then
        echo "psplash still running after wait; starting EdgeAI GUI anyway" >&2
    fi
}

repaint_framebuffer() {
    if [ -x "$EDGEAI_WALLPAPER_UPDATE" ]; then
        echo "Applying wallpaper to linux frame buffer"
        "$EDGEAI_WALLPAPER_UPDATE" || true
    fi
}

start_gui() {
    local EDGEAI_GUI_APP_CMD="$EDGEAI_GUI_APP -platform linuxfb &"
    eval $EDGEAI_GUI_APP_CMD
    echo $! > $PIDFILE
}

stop_gui() {
    if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
        echo 'Service not running' >&2
        return 1
    fi
    echo 'Stopping EdgeAI GUI App ..' >&2
    kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
}

# Use this to wait for emptty to be ready & kill it as it comes up.
# This is the same service model used by the working j721e-sk image.
kill_emptty() {
    systemctl stop emptty.service
}

case "$1" in
    start )
        source $EDGEAI_INIT_SCRIPT
        if [ $ENABLE_GUI -eq 1 ]; then
            wait_for_psplash_exit
            repaint_framebuffer
            echo "Starting edgeai-gui-app..."
            start_gui
        fi
        # Wait for network to come up, Set time
        for i in `seq 1 3`; do
            timeout 10 ntpd -s
            if [ $? -eq 0 ]; then
                echo "ntpd successful"
                break
            fi
        done
        killall ntpd || true
    ;;
    stop )
        if [ $ENABLE_GUI -eq 1 ]; then
            stop_gui
        fi
        source $EDGEAI_INIT_SCRIPT
        repaint_framebuffer
    ;;
    restart )
        if [ $ENABLE_GUI -eq 1 ]; then
            stop_gui
            wait_for_psplash_exit
            repaint_framebuffer
            start_gui
        fi
    ;;
    kill_emptty )
        kill_emptty
    ;;
    * )
        echo "Usage: $0 {start|stop|restart}"
esac

