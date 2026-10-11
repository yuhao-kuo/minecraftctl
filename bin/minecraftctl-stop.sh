#!/bin/bash


function minecraftctl_stop() {
    # arg1: conf path
    # arg2: var path
    # arg3: server name

    local _conf _var _server_name _docker_main_yml _docker_volume_yml _exec_env _server_env _server_stat
    _conf=$MINECRAFTCTL_CONF
    _var=$MINECRAFTCTL_VAR
    _server_name=$1

    _server_stat=`docker ps --filter "name=$_server_name" --format "{{.Names}}"`

    if [ "$_server_stat" == "$_server_name" ]; then
        _docker_main_yml=`echo "${_conf}/env/docker-compose.yml" | sed 's/\/\//\//g'`
        _docker_volume_yml=`echo "${_var}/${_server_name}/docker-volume.yml" | sed 's/\/\//\//g'`
        _exec_env=`echo "${_conf}/env/exec.env" | sed 's/\/\//\//g'`
        _server_env=`echo "${_var}/${_server_name}/server.env" | sed 's/\/\//\//g'`
        docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --env-file ${_exec_env} --env-file ${_server_env} --project-name "mc_container_${_server_name}" stop
    else
        echo "[Info] Not search \"$_server_name\" is running."
    fi

}

