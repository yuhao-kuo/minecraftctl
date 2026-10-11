#!/bin/bash

function minecraftctl_sh() {
    # arg1: server
    # arg2-n: arguments

    local _params_count
    _params_count=1
    if [ $# -lt $_params_count ]; then
        echo "[Error] parameter count $# < $_params_count"
        exit 1
    fi

    _server_stat=`docker ps --filter "name=$_server_name" --format "{{.Names}}"`

    if [ "$_server_stat" == "$_server_name" ]; then
        docker exec -it $1 /bin/bash
    else
        echo "[Warning] server \"${_server_name}\" not running."
    fi
}
