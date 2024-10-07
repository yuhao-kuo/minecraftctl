#!/bin/bash

function minecraftctl_exec() {
    # arg1: server
    # arg2-n: arguments
    local _SERVER
    _SERVER=`docker ps --filter "name=$1" --format "{{.Names}}"`
    if [ "$_SERVER" == "$1" ]; then
        docker exec -it $1 rconclt -c /opt/mc.conf/rcon.conf minecraft ${@:2} 
    else
        echo "[Error] Server \"$1\" not found."
    fi
}
