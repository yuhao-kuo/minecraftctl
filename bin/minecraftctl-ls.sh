#!/bin/bash

function minecraftctl_ls() {

    _CONFIG="${MINECRAFTCTL_CONF_FILE}"
    _IMAGE=`cat $_CONFIG | grep MINECRAFTCTL_DEFAULT_IMAG | cut -d '=' -f 2`
    if [ $_IMAGE == "" ]; then
        _IMAGE="minecraftctl_server"
    fi

    docker ps -f "ancestor=$_IMAGE" -f "status=running" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

}

