#!/bin/bash


function __mcmap_proxy_conf_file_init() {

    echo "func __mcmap_proxy_conf_file_init begin"

    # minecraft config file
    if [ "$MINECRAFTCTL_CONF_FILE" == "" ] || [ ! -f "$MINECRAFTCTL_CONF_FILE" ]; then
        echo "[Error] variable \"MINECRAFTCTL_CONF_FILE\" not found."
        exit 1
    fi
    source $MINECRAFTCTL_CONF_FILE

    # string check
    if [ "$_MCMAP_PROXY_YML" == "" ]; then
        _MCMAP_PROXY_YML="$MINECRAFTCTL_CONF/env/mcmap-proxy.yml"
    fi

    if [ "$_MCMAP_PROXY_ENV" == "" ]; then
        _MCMAP_PROXY_ENV="$MINECRAFTCTL_CONF/env/mcmap-default.env"
    fi

    # file check
    if [ ! -f "$_MCMAP_PROXY_YML" ] || [ ! -f "$_MCMAP_PROXY_ENV" ]; then
        echo "[Erro] container setting file not found"
        exit 1
    fi

    # get proxy server container name
    _MCMAP_PROXY_NAME=`grep MCMAP_DEFAULT_PROXY_NAME $_MCMAP_PROXY_ENV | awk -F '=' '{print $2}'`

    echo "func __mcmap_proxy_conf_file_init end"
}

function __mcmap_proxy_create() {
    _YML=$1
    _ENV=$2
    
    echo "func __mcmap_proxy_create begin"
    echo "yml = $_YML"
    echo "env = $_ENV"
    # create file setting
    CONFDIR=`grep MCMAP_DEFAULT_PROXY_CONF_DIR $_ENV | awk -F '=' '{print $2}'`
    echo "CONFDIR $CONFDIR"
    if [ ! -d "$CONFDIR" ]; then
        mkdir -p $CONFDIR
    fi

    ROUTEDIR=`grep MCMAP_DEFAULT_PROXY_ROUTE_DIR $_ENV | awk -F '=' '{print $2}'`
    echo "ROUTEDIR $ROUTEDIR"
    if [ ! -d "$ROUTEDIR" ]; then
        mkdir -p $ROUTEDIR
    fi

    local NGINX_CONF=`echo "$CONFDIR/nginx.conf" | sed 's/\/\//\//g'`
    if [ ! -f "$NGINX_CONF" ]; then
        cp $MINECRAFTCTL_CONF/templates/mcmap_proxy_nginx.conf.temp $NGINX_CONF
    fi

    # create container
    docker compose --file $_YML --env-file $_ENV --project-name $_MCMAP_PROXY_NAME up --no-start
    
    echo "func __mcmap_proxy_create end"
}

function mcmap_proxy_start() {
    _MCMAP_PROXY_YML=$1
    _MCMAP_PROXY_ENV=$2

    echo "func mcmap_proxy_start begin"

    # proxy config init
    __mcmap_proxy_conf_file_init

    # confirm mcmap proxy is exists
    local _CHK=`docker compose ls -a | grep $_MCMAP_PROXY_NAME`
    echo "_CHK $_CHK"
    if [ "$_CHK" == "" ]; then
        __mcmap_proxy_create $_MCMAP_PROXY_YML $_MCMAP_PROXY_ENV
    fi

    # start container
    local _CHK_ISRUN=`docker compose ls | grep $_MCMAP_PROXY_NAME`
    echo "_CHK_ISRUN $_CHK_ISRUN"
    if [ "$_CHK_ISRUN" == "" ]; then
        local MCMAP_LOCATION_DIR=`grep MCMAP_DEFAULT_PROXY_ROUTE_DIR $_MCMAP_PROXY_ENV | awk -F '=' '{print $2}'`
        _CHK=`find $MCMAP_LOCATION_DIR -type f 2> /dev/null | wc -l`
        echo "_CHK_2 $_CHK"
        if [ $_CHK -ne 0 ]; then
            echo "docker compose --file $_MCMAP_PROXY_YML --env-file $_MCMAP_PROXY_ENV --project-name $_MCMAP_PROXY_NAME start
"
            docker compose --file $_MCMAP_PROXY_YML --env-file $_MCMAP_PROXY_ENV --project-name $_MCMAP_PROXY_NAME start
        fi
    else
        # reload config of nginx
        echo "docker exec -it $_MCMAP_PROXY_NAME nginx -s reload"
        docker exec -it $_MCMAP_PROXY_NAME nginx -s reload 
    fi

    echo "func mcmap_proxy_start end"
}

function mcmap_proxy_stop() {
    _MCMAP_PROXY_YML=$1
    _MCMAP_PROXY_ENV=$2
    echo "func mcmap_proxy_stop begin"

    # proxy config init
    __mcmap_proxy_conf_file_init

    # check docker compose is work
    local CHK=`docker compose ls -a | grep $_MCMAP_PROXY_NAME`
    if [ "$CHK" == "" ]; then
        echo "mcmap proxy not running"
        exit 0
    fi

    # stop container
    local _CHK_ISRUN=`docker compose ls | grep $_MCMAP_PROXY_NAME`
    if [ "$_CHK_ISRUN" == "" ]; then
        local MCMAP_LOCATION_DIR=`grep MCMAP_DEFAULT_PROXY_ROUTE_DIR $_MCMAP_PROXY_ENV | awk -F '=' '{print $2}'`
        _CHK=`find $MCMAP_LOCATION_DIR -type f 2> /dev/null | wc -l`
        if [ $_CHK -eq 0 ]; then
            docker compose --file $_MCMAP_PROXY_YML --env-file $_MCMAP_PROXY_ENV --project-name $_MCMAP_PROXY_NAME stop
        else
            docker exec -it $_MCMAP_PROXY_NAME nginx -s reload 
        fi
    fi

    echo "func mcmap_proxy_stop end"
}

