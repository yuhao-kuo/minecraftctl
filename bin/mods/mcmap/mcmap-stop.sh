#!/bin/bash

function mcmap_stop() {
    local _mcmap_server_name="${1}_mcmap"
    local _conf=$MINECRAFTCTL_CONF
    local _var=$MINECRAFTCTL_VAR
    if [ -d "${_var}/${1}" ]; then
        # TODO: remove proxy conf link and then reload proxy
        local _mcmap_main_yml=`echo "${_conf}/env/mcmap-compose.yml" | sed 's/\/\//\//g'`
        local _mcmap_env=`echo "${_var}/${1}/mods/mcmap/mcmap.env" | sed 's/\/\//\//g'`
        source $_mcmap_env
        local _server_env=`echo "${_var}/${1}/server.env" | sed 's/\/\//\//g'`
        source $_server_env
        local _docker_is_running=`docker ps -f "ancestor=${MCMAP_IMAGE}" -f "status=running" -f "status=restarting" --format "table {{.Names}}" | grep ${_mcmap_server_name}`
        
        if [ ! "$_docker_is_running" == "" ]; then
            docker compose --file ${_mcmap_main_yml} --env-file ${_mcmap_env} --env-file ${_server_env} --project-name ${_mcmap_server_name} stop
        fi
    fi
}

