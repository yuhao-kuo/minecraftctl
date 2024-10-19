#!/bin/bash


function __minecraftctl_host_copy2_container() {
    # arg1: server name
    # arg2: conf
    # arg3: var
    # arg4: host data path
    # arg5: container data path
    
    local _server_name _conf _var _host_data_path _container_data_path _docker_main_yml _docker_volume_yml _exec_env _server_env _source_yml _source_env _init_yml _is_running

    _server_name=$1
    _conf=$2
    _var=$3
    _host_data_path=$4
    _container_data_path=$5

    _docker_main_yml=`echo "${_conf}/env/docker-compose.yml" | sed 's/\/\//\//g'`
    _docker_volume_yml=`echo "${_var}/${_server_name}/docker-volume.yml" | sed 's/\/\//\//g'`
    _exec_env=`echo "${_conf}/env/exec.env" | sed 's/\/\//\//g'`
    _server_env=`echo "${_var}/${_server_name}/server.env" | sed 's/\/\//\//g'`
    _source_yml=`echo "${_conf}/env/copy-compose.yml" | sed 's/\/\//\//g'`
    _source_env=`echo "${_var}/${_server_name}/copy-source.env" | sed 's/\/\//\//g'`
    _init_yml=`echo "${_conf}/env/init-compose.yml" | sed 's/\/\//\//g'`

    # build source temp env file
    echo "SOURCEPATH=$_host_data_path" > $_source_env

    # start container
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --file ${_init_yml} --file ${_source_yml} --env-file ${_exec_env} --env-file ${_server_env} --env-file $_source_env up -d

    _is_running=`docker ps --filter "name=init_$_server_name" --filter "status=running" --format "{{.Names}}"`

    if [ "$_is_running" != "" ]; then

        # copy data
        docker exec init_${_server_name} cp -R /opt/source/. /opt/mcworld

        # stop container
        docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --file ${_init_yml} --file ${_source_yml} --env-file ${_exec_env} --env-file ${_server_env} --env-file $_source_env down
    else
        echo "[Warring] Server $_server_name is running."
    fi

    # remove source temp env file
    if [ -f "$_source_env" ]; then
        rm -rf $_source_env
    fi
}


function __minecraftctl_data_copy() {
    # arg1: server name
    # arg2: conf
    # arg3: var
    # arg4: dirction (H2C or C2H)
    # arg5: host data path
    # arg6: container data path
    
    local _server_name _conf _var _direction _host_data_path _container_data_path

    _server_name=$1
    _conf=$2
    _var=$3
    _direction=$4
    _host_data_path=$5
    _container_data_path=$6

    # check command
    if [ "$_direction" == "H2C" ]; then
        __minecraftctl_host_copy2_container $_server_name $_conf $_var $_host_data_path $_container_data_path
    elif [ "$_direction" == "C2H" ]; then
        _cp_cmd=""
    else
        echo "Command Not found."
    fi
}

