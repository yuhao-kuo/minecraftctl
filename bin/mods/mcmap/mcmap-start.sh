#!/bin/bash

# TODO: this funcion miss check yml and env file are exists.

function mcmap_start() {
    local _mcmap_server_name="${1}_mcmap"
    local _conf=$MINECRAFTCTL_CONF
    local _var=$MINECRAFTCTL_VAR
    if [ -d "${_var}/${1}" ]; then
        local _docker_is_running=`docker ps -f "ancestor=${MCMAP_IMAGE}" -f "status=running" --format "table {{.Names}}" | grep ${_mcmap_server_name}`
        
        if [ "$_docker_is_running" == "" ]; then
            local _mcmap_main_yml=`echo "${_conf}/env/mcmap-compose.yml" | sed 's/\/\//\//g'`
            local _mcmap_env=`echo "${_var}/${1}/mods/mcmap/mcmap.env" | sed 's/\/\//\//g'`
            local _server_env=`echo "${_var}/${1}/server.env" | sed 's/\/\//\//g'`
            docker compose --file ${_mcmap_main_yml} --env-file ${_mcmap_env} --env-file ${_server_env} --project-name ${_mcmap_server_name} start

            local _docker_is_runed=`docker ps -f "ancestor=${MCMAP_IMAGE}" -f "status=running" --format "table {{.Names}}" | grep ${_mcmap_server_name}`
            if [ ! "$_docker_is_runed" == "" ]; then
                # TODO: mcmap started, then link proxy conf and reload proxy
                echo "started"
            fi
        fi
    fi
}

