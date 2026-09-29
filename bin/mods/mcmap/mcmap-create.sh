#!/bin/bash

function __mcmap_create_container_conf() {
    local SERVERNAME=$1
    local WORLD_PWD=$2
    local WEB_PWD=$3
    local DOCKER_IMAGE=$4
    local DOCKER_IMAGE_VERSION=$5
    local MCCTL_DEFAULT_IMAGE=$6
    local MCCTL_DEFAULT_IMAGE_VERSION=$7
    local CREATENAME="${SERVERNAME}_mcmap_create"
    # create mcmap web config
    docker run --rm -it \
        --name ${CREATENAME} \
        -p 8100:8100 \
        -v"${WEB_PWD}/config:/app/config" \
        -v "${WORLD_PWD}/world:/app/world" \
        -v "${WEB_PWD}/data:/app/data" \
        -v "${WEB_PWD}/web:/app/web" \
        ${DOCKER_IMAGE}:${DOCKER_IMAGE_VERSION} \
        -r -u -w
    # accept mcmap package download
    docker run --rm -it \
        -u root \
        --name ${CREATENAME} \
        -v"${WEB_PWD}/config:/app/config" \
        -v "${WORLD_PWD}/world:/app/world" \
        -v "${WEB_PWD}/data:/app/data" \
        -v "${WEB_PWD}/web:/app/web" \
        ${MCCTL_DEFAULT_IMAGE}:${MCCTL_DEFAULT_IMAGE_VERSION} \
        /usr/bin/sed -i 's/accept-download:\ false/accept-download:\ true/' /app/config/core.conf
}

function __mcmap_create_service_conf() {
    local NCMAP_SERVER_NAME=$1
    local MCMAP_VAR=$2
    local MCMAP_IMAGE=$3
    local MCMAP_IMAGE_VERSION=$4

    local MCMAP_WEB_DIR=$5
    local MCMAP_WORLD_DIR=$6
    local MCMAP_CONF_DIR=$7
    local MCMAP_CONF=`echo "${MCMAP_CONF_DIR}/mcmap.env" | sed 's/\/\//\//g'`
    
    local _CHK=`docker compose ls -a | grep $NCMAP_SERVER_NAME`
    if [ "$_CHK" != "" ]; then
        echo "Server $NCMAP_SERVER_NAME already created."
        exit 0
    fi

    if [ ! -d "$MCMAP_CONF_DIR" ]; then
        mkdir -p $MCMAP_CONF_DIR
    fi

    echo "MCMAP_IMAGE=${MCMAP_IMAGE}" > $MCMAP_CONF
    echo "MCMAP_IMAGE_VERSION=${MCMAP_IMAGE_VERSION}" >> $MCMAP_CONF
    echo "MCMAP_WEB_DIR=${MCMAP_WEB_DIR}" >> $MCMAP_CONF
    echo "MCMAP_WORLD_DIR=${MCMAP_WORLD_DIR}" >> $MCMAP_CONF

    # add docker compose create
    local MCMAP_YML="$MCMAP_VAR/env/mcmap-compose.yml"
    docker compose --file $MCMAP_YML --env-file $MCMAP_CONF --project-name $MCMAP_SERVER_NAME up --no-start

}

function mcmap_create() {
    local _SERVER=$1
    local _MCMAP_IMAGE=$2
    local _MCMAP_IMAGE_VERSION=$3
    local _MCMAP_WEB_DIR=$4

    local _VAR=$MINECRAFTCTL_VAR
    local _CONF=$MINECRAFTCTL_CONF
    local _BIN=$MINECRAFTCTL_BIN
    local _MCMAP_BIN=`echo "${_BIN}/mods/mcmap" | sed 's/\/\//\//g'`

    # server check
    if [ "`ls ${_VAR}/${_SERVER} 2> /dev/null`" == "" ]; then
        echo "Server ${SERVER} not found."
        exit 0
    fi

    # mcmap web directory check
    if [ "$_MCMAP_WEB_DIR" == "" ]; then
        _MCMAP_WEB_DIR=`cat ${_CONF}/env/mcmcp-default.env | grep MCMAP_DEFAULT_WEB_DIR | awk -F '=' '{print $2}'`
    fi

    if [ ! -d "$_MCMAP_WEB_DIR" ]; then
        mkdir -p $_MCMAP_WEB_DIR 
    fi

    local _SRV_ENV=`echo "${_VAR}/${_SERVER}/server.env" | sed 's/\/\//\//g'`
    local _WORLD_DIR=`cat ${_SRV_ENV} | grep MCWORLD | awk -F '=' '{print {$2}'`
    local _MCMAP_CONF_DIR=`echo "${_VAR}/${_SERVER}/mods/mcmap" | sed 's/\/\//\//g'`

    local _MCCTL_IMAGE=`cat ${_SRV_ENV} | grep IMAGE_NAME | awk -F '=' '{print {$2}'`
    local _MCCTL_IMAGE_VERSION="latest"

    # check proxy and check network
    source ${_MCMAP_BIN}/mcmap_network_utils.sh
    mcmap_network_create mcmap_net
    
    # create proxy
    local _MCMAP_PROXY_YML="${_CONF}/env/mcmap-compose.yml"
    local _MCMAP_PROXY_ENV="${_VAR}/${_SERVER}/mods/mcmap/mcmap.env"
    source ${_MCMAP_BIN}/mcmap_proxy.sh
    # add create proxy route
    mcmap_proxy_create_route "${_SERVER}_mcmap"
    mcmap_proxy_start $_MCMAP_PROXY_YML $_MCMAP_PROXY_ENV

    # create config to service
    __mcmap_create_container_conf ${_SERVER} ${_WORLD_DIR} ${_MCMAP_WEB_DIR} ${_VAR} ${_MCMAP_IMAGE} ${_MCMAP_IMAGE_VERSION} ${_MCCTL_IMAGE} ${_MCCTL_IMAGE_VERSION}

    # create config
    local COMPOSE_NAME="${_SERVER}_mcmap_server"
    __mcmap_create_service_conf $COMPOSE_NAME $_VAR $_MCMAP_IMAGE $_MCMAP_IMAGE_VERSION $_MCMAP_WEB_DIR $_WORLD_DIR $_MCMAP_CONF_DIR

}

