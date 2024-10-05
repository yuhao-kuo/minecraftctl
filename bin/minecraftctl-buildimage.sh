#!/bin/bash


function minecraftctl_buildimage() {
    # arg1: docker file direction.

    local WORK_DIR DOCKERFILE_DIR REMAPUSER
    DOCKERFILE_DIR=$1

    if [ ! -d "$1" ]; then
        echo "direction not found, \"$1\""
    else
        REMAPUSER=`cat /etc/docker/daemon.json | grep '"userns-remap"' | sed s/\"//g | awk '{print $2}'`
        if [ "$REMAPUSER" == "" ]; then
            docker build -t minecraftctl_server:latest \
                --build-arg USER=`whoami` \
                --build-arg USERID=`id -u` \
                --build-arg GROUPID=`id -g` ${DOCKERFILE_DIR}
        else
            docker build -t minecraftctl_server:latest \
                --build-arg USER=minecraft \
                --build-arg USERID=1000 \
                --build-arg GROUPID=1000 ${DOCKERFILE_DIR}
        fi
    fi
}

