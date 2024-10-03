#!/bin/bash

function minecraftctl_init_change_world_properties() {
    local _server_name
    _server_name=$1

    # edit properties for user
    docker exec -it ${_server_name} vim /opt/mcworld/server.properties

    # rewrite RCON setting
    docker exec -it ${_server_name} sed -e 's/enable-rcon=false/enable-rcon=true/g' -i /opt/mcworld/server.properties
    docker exec -it ${_server_name} sed -e 's/rcon.password=/rcon.password=1234/g' -i /opt/mcworld/server.properties
}

function minecraftctl_init_world() {
    local _conf _var _server_name _docker_main_yml _docker_volume_yml _exec_env _server_env _checkfunc _count
    _conf=$1
    _var=$2
    _server_name=$3

    _docker_main_yml=`echo "${_conf}/env/docker-compose.yml" | sed 's/\/\//\//g'`
    _docker_volume_yml=`echo "${_var}/${_server_name}/docker-volume.yml" | sed 's/\/\//\//g'`
    _exec_env=`echo "${_conf}/env/exec.env" | sed 's/\/\//\//g'`
    _server_env=`echo "${_var}/${_server_name}/server.env" | sed 's/\/\//\//g'`

    # start container
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --env-file ${_exec_env} --env-file ${_server_env} up -d

    # double check that is ready.
    _count=0
    _checkfunc="docker ps | grep ${_server_name}"
    while [ "`eval $_checkfunc`" == "" ]
    do
        _count=`expr $_count + 1`
        if [ $_count -ge 20 ]; then
            echo "timeout"
            break
        fi
        sleep 5
    done

    # double check that is ready.
    _count=0
    _checkfunc="docker exec -it ${_server_name} find /opt/mcworld -name server.properties"
    while [ "`eval $_checkfunc`" == "" ]
    do
        _count=`expr $_count + 1`
        if [ $_count -ge 20 ]; then
            echo "timeout"
            break
        fi
        sleep 5
    done

    # change server.properties RCON setting
    if [ $_count -lt 20 ]; then
        minecraftctl_init_change_world_properties ${_server_name}
    fi

    # stop minecraft server
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --env-file ${_exec_env} --env-file ${_server_env} down

    # create container
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --env-file ${_exec_env} --env-file ${_server_env} --project-name "mc_container_${_server_name}"  up --no-start
}

function minecraftctl_init() {
    # arg1: server name
    # arg2: conf directory
    # arg3: var directory

    local _server_name _conf_path _var_path

    # variable count check
    if [ $# -ne 3 ]; then
        echo "miss argument or over argument"
        exit
    fi

    _server_name=$1
    if [ "$_server_name" == "" ]; then
        echo "server name is empty"
        exit
    fi
    _conf_path=$2
    if [ "$_conf_path" == "" ]; then
        echo "config directory path is empty"
        exit
    fi
    _var_path=$3
    if [ "$_var_path" == "" ]; then
        echo "variable directory path is empty"
        exit
    fi

    # call function
    minecraftctl_init_world $_conf_path $_var_path $_server_name

}

