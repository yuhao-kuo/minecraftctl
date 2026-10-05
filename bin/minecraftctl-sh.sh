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

    docker exec -it $1 /bin/bash 
}
