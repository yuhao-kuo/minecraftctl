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
}

function __minecraftctl_init_wait_ready() {
    # arg1: container name
    # successfully return 0, else return 1
    local _name _i _running _success _failed
    _name=$1
    _success=0
    _failed=1
    if [ "${_name}" == "" ]; then
        echo "[Error] server name is empty."
        return $_failed
    fi
    for ((_i = 0; _i < 20; _i++)); do
        _running=`docker inspect -f '{{.State.Running}}' ${_name} 2>/dev/null`
        if [ "$_running" == "true" ]; then
            return $_success
        elif  [ "$_running" == "" ] || [ "$_running" == "false" ]; then
            sleep 2
        fi
    done

    echo "[Error] timeout waiting for container ${_name}"
    return $_failed
}

function __minecraft_init_wait_file_created() {
    # arg1: container name
    # arg2: target file name
    # successfully return 0, else return 1
    local _cnt _name _target _success _failed
    _name=$1
    _target=$2
    _success=0
    _failed=1
    if [ "${_name}" == "" ] || [ "${_target}" == "" ]; then
        echo "[Error] container name or target is empty."
        return $_failed
    fi
    for ((_cnt = 0; _cnt < 10; _cnt++)); do
        if docker exec ${_name} find /opt/mcworld -name ${_target} 2>/dev/null | grep -q .; then
            return $_success
        fi
        sleep 2
    done
    echo "[Error] Server file \"${_target}\" finding timout."
    return $_failed
}

function __minecraftctl_init_world() {
    local _conf _var _server_name _has_world _docker_main_yml _docker_volume_yml _exec_env _server_env _file
    _conf=$1
    _var=$2
    _server_name=$3
    _has_world=$4
    local _success _failed
    _success=0
    _failed=1

    _docker_main_yml=`echo "${_conf}/env/docker-compose.yml" | sed 's/\/\//\//g'`
    _docker_volume_yml=`echo "${_var}/${_server_name}/docker-volume.yml" | sed 's/\/\//\//g'`
    _exec_env=`echo "${_conf}/env/exec.env" | sed 's/\/\//\//g'`
    _server_env=`echo "${_var}/${_server_name}/server.env" | sed 's/\/\//\//g'`
    
    if [ "$_has_world" == "" ]; then
        _file=""
    else
        _file=`echo "--file ${_conf}/env/init-compose.yml" | sed 's/\/\//\//g'`
    fi

    local _ready=$_failed

    # start container
    if docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} $_file --env-file ${_exec_env} --env-file ${_server_env} up -d; then
        if [ "$_file" == "" ]; then
            # these functions return 0 on success, 1 otherwise
            __minecraftctl_init_wait_ready ${_server_name}
            _ready=$?
            if [ $_ready -eq $_success ]; then
                __minecraft_init_wait_file_created ${_server_name} server.properties
                _ready=$?
            fi
        else
            _ready=$_success
        fi
    else
        echo "[Error] docker compose up failed"
    fi

    # change server.properties RCON setting
    if [ $_ready -eq $_success ]; then
        __minecraftctl_init_change_world_properties ${_server_name} $_file
    fi

    # stop minecraft server (always clean up)
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} $_file --env-file ${_exec_env} --env-file ${_server_env} down

    if [ $_ready -ne $_success ]; then
        echo "[Error] init failed for server \"${_server_name}\""
        return 1
    fi

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
    return $?

}

