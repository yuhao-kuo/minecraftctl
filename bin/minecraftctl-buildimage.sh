#!/bin/bash


function minecraftctl_buildimage() {
    # arg1: docker file direction.

    local WORK_DIR DOCKERFILE_DIR REMAPUSER SUBUID SUBGID
    DOCKERFILE_DIR=$1

    if [ ! -d "$1" ]; then
        echo "direction not found, \"$1\""
    else
        REMAPUSER=`cat /etc/docker/daemon.json | grep '"userns-remap"' | sed s/\"//g | awk '{print $2}'`
        if [ "$_docker_remap_user" == "" ]; then
            docker build -t minecraftctl_server:latest \
                --build-arg USER=`whoami` \
                --build-arg USERID=`id -u` \
                --build-arg GROUPID=`id -g` ${DOCKERFILE_DIR}
        else
            SUBUID=`cat /etc/subuid | grep $REMAPUSER | awk -F':' '{print $2}'`
            SUBGID=`cat /etc/subgid | grep $REMAPUSER | awk -F':' '{print $2}'`
            SUBUID=`expr $SUBUID + 1000`
            SUBGID=`expr $SUBGID + 1000`
            docker build -t minecraftctl_server:latest \
                --build-arg USER=minecraft \
                --build-arg USERID=$SUBUID \
                --build-arg GROUPID=$SUBGID ${DOCKERFILE_DIR}
        fi
    fi
}

