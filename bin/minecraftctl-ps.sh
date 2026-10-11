#!/bin/bash

function minecraftctl_ps() {

    _CONFIG="${MINECRAFTCTL_CONF_FILE}"
    _IMAGE=`grep MINECRAFTCTL_DEFAULT_IMAG "$_CONFIG" | cut -d '=' -f 2`
    if [ "$_IMAGE" == "" ]; then
        _IMAGE="minecraftctl_server"
    fi

    docker ps -a -f "ancestor=$_IMAGE" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

}
