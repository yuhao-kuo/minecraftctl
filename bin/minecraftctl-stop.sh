#!/bin/bash


function minecraftctl_stop() {
    # arg1: conf path
    # arg2: var path
    # arg3: server name

    local _conf _var _server_name _docker_main_yml _docker_volume_yml _exec_env _server_env
    _conf=$1
    _var=$2
    _server_name=$3

    _docker_main_yml=`echo "${_conf}/env/docker-compose.yml" | sed 's/\/\//\//g'`
    _docker_volume_yml=`echo "${_var}/${_server_name}/docker-volume.yml" | sed 's/\/\//\//g'`
    _exec_env=`echo "${_conf}/env/exec.env" | sed 's/\/\//\//g'`
    _server_env=`echo "${_var}/${_server_name}/server.env" | sed 's/\/\//\//g'`

    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --env-file ${_exec_env} --env-file ${_server_env} --project-name "mc_container_${_server_name}" stop

}

