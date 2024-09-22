#!/bin/bash


function minecraftctl_buildimage() {
    # arg1: docker file direction.
    local WORK_DIR DOCKERFILE_DIR
    DOCKERFILE_DIR=$1
    if [ ! -d "$1" ]; then
        echo "direction not found, \"$1\""
    else
        docker build -t minecraftctl_server:latest \
            --build-arg USER=`whoami` \
            --build-arg USERID=`id -u` \
            --build-arg GROUPID=`id -g` ${DOCKERFILE_DIR}
    fi
}

