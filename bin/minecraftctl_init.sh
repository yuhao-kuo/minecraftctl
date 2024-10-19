#!/bin/bash

function __minecraftctl_init_change_world_properties() {
    local _server_name _no_edit_server_properties
    _server_name=$1
    _no_edit_server_properties=$2

    if [ "$_no_edit_server_properties" == "" ]; then
        # edit properties for user
        docker exec -it ${_server_name} vim /opt/mcworld/server.properties
    else
        _server_name=init_${_server_name}
    fi

    # rewrite RCON setting
    docker exec -it ${_server_name} sed -i '/^enable-rcon=/c\enable-rcon=true' /opt/mcworld/server.properties
    docker exec -it ${_server_name} sed -i '/^rcon.password=/c\rcon.password=1234' /opt/mcworld/server.properties
    # docker exec -it ${_server_name} sed -e 's/enable-rcon=false/enable-rcon=true/g' -i /opt/mcworld/server.properties
    # docker exec -it ${_server_name} sed -e 's/rcon.password=/rcon.password=1234/g' -i /opt/mcworld/server.properties
}

function __minecraftctl_init_world() {
    local _conf _var _server_name _has_world _docker_main_yml _docker_volume_yml _exec_env _server_env _checkfunc _count _file
    _conf=$1
    _var=$2
    _server_name=$3
    _has_world=$4

    _docker_main_yml=`echo "${_conf}/env/docker-compose.yml" | sed 's/\/\//\//g'`
    _docker_volume_yml=`echo "${_var}/${_server_name}/docker-volume.yml" | sed 's/\/\//\//g'`
    _exec_env=`echo "${_conf}/env/exec.env" | sed 's/\/\//\//g'`
    _server_env=`echo "${_var}/${_server_name}/server.env" | sed 's/\/\//\//g'`
    
    if [ "$_has_world" == "" ]; then
        _file=""
    else
        _file=`echo "--file ${_conf}/env/init-compose.yml" | sed 's/\/\//\//g'`
    fi

    # start container
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} $_file --env-file ${_exec_env} --env-file ${_server_env} up -d

    _count=0
    if [ "$_file" == "" ]; then
        # double check that is ready.
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
    fi

    # change server.properties RCON setting
    if [ $_count -lt 20 ]; then
        __minecraftctl_init_change_world_properties ${_server_name} $_file
    fi

    # stop minecraft server
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} $_file --env-file ${_exec_env} --env-file ${_server_env} down

    # create container
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --env-file ${_exec_env} --env-file ${_server_env} --project-name "mc_container_${_server_name}"  up --no-start
}

function __minecraftctl_init() {
    # arg1: server name
    # arg2: conf directory
    # arg3: var directory
    # arg4: Don't start the minecraft to init environment

    local _server_name _conf_path _var_path

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
    __minecraftctl_init_world $_conf_path $_var_path $_server_name $4

}

