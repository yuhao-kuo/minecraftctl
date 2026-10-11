#!/bin/bash

function __minecraftctl_remove_service_check() {
    local _success _failed _is_running _not_found
    _success=0
    _failed=1
    _is_running=2
    _not_found=3

    local _service_name _compose_is_exist _containers _container_check
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        return $_failed
    fi

    _compose_is_exist=`docker compose ls -a --filter "name=${_service_name}" --format json`
    if [ "$_compose_is_exist" == "[]" ]; then
        return $_not_found
    fi

    _containers=`minecraftctl ps | grep ${_service_name}`
    while IFS= read -r line; do
        _container_check=`echo $line | awk '{print $2}'`
        if [ "${_container_check}" == "${_service_name}" ]; then
            local _runtime
            _runtime=`echo $line | awk '{print $3}'`
            if [ "${_runtime}" == "Up" ]; then
                return $_is_running
            fi
            break
        fi
    done <<< "${_containers}"

    return $_success
}

function __minecraftctl_remove_volume() {
    local _success _failed
    _success=0
    _failed=1

    local _service_name _volume _check_volume_exist
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] remove volume operation failed, the service name is empty."
        return $_failed
    fi

    # remove volume
    _volume="mcctlvol_${_service_name}"
    _check_volume_exist=`docker volume inspect ${_volume} 2> /dev/null`
    if [ "${_check_volume_exist}" != "[]" ]; then
        docker volume rm ${_volume}
    fi
    
    # check volume and retrun
    _check_volume_exist=`docker volume inspect ${_volume} 2> /dev/null`
    if [ "${_check_volume_exist}" != "[]" ]; then
        return $_failed
    fi
    
    return $_success
}

function __minecraftctl_remove_world_directory() {
    local _success _failed
    _success=0
    _failed=1

    local _service_name _default_world _world_dir
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        return $_failed
    fi

    _default_world=$MINECRAFTCTL_DEFAULT_WORLD
    _world_dir=`echo "${_default_world}/${_service_name}" | sed 's/\/\//\//g'`

    if [ -d "${_world_dir}" ]; then
        rm -rf "${_world_dir}"
    else
        echo "[Info] the directory \"${_world_dir}\" not fount, continued."
    fi

    return $_success
}

function __minecraftctl_remove_service_directory() {
    local _success _failed
    _success=0
    _failed=1

    local _service_name _var _service_dir
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        return $_failed
    fi

    _var=$MINECRAFTCTL_VAR
    _service_dir=`echo "${_var}/${_service_name}" | sed 's/\/\//\//g'`

    if [ -d "${_service_dir}" ]; then
        rm -rf "${_service_dir}"
    else
        echo "[Info] the directory \"${_service_dir}\" not fount, continued."
    fi

    return $_success
}

function __minecraftctl_remove_service() {
    local _service_name _var _service_dir
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        return $_failed
    fi

    local _conf _var
    _conf=$MINECRAFTCTL_CONF
    _var=$MINECRAFTCTL_VAR
    local _success _failed _check_result
    _success=0
    _failed=1

    local _docker_main_yml _docker_volume_yml _exec_env _server_env
    _docker_main_yml=`echo "${_conf}/env/docker-compose.yml" | sed 's/\/\//\//g'`
    _docker_volume_yml=`echo "${_var}/${_service_name}/docker-volume.yml" | sed 's/\/\//\//g'`
    _exec_env=`echo "${_conf}/env/exec.env" | sed 's/\/\//\//g'`
    _server_env=`echo "${_var}/${_service_name}/server.env" | sed 's/\/\//\//g'`

    # remove container
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --env-file ${_exec_env} --env-file ${_server_env} --project-name "mc_container_${_service_name}" down

    # container status report
    _check_result=`docker compose ls -a --filter "name=${_service_name}" --format json`
    if [ "${_check_result}" == "[]" ]; then
        return $_success
    else
        return $_failed
    fi
}

function minecraftctl_remove() {

    local _success _failed _is_running _not_found
    _success=0
    _failed=1
    _is_running=2
    _not_found=3

    local _service_name
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        return $_failed
    fi

    # feedback for user to confirm drop a world
    while true; do
        read -p "Do you want to continue? (y/n): " choice
        case "$choice" in
            [yY] )
                break
                ;;
            [nN] )
                echo "Stopped."
                exit $_success
                ;;
            * )
                echo "Invalid input. Please enter y or n."
                ;;
        esac
    done

    source ${MINECRAFTCTL_CONF_FILE}
    source ${MINECRAFTCTL_BIN}/minecraftctl_check_server_exist.sh
    
    local _check=$_success

    # check server is exist
    if [ -z "$_service_name" ]; then
        echo "[Error] server name is empty."
        return $_failed
    fi

    # check server is running
    __minecraftctl_remove_service_check ${_service_name} || _check=$?
    if [ ${_check} -eq ${_is_running} ]; then
        echo "[Info] Server \"${_service_name}\" is running, stopped."
        return $_failed
    elif [ ${_check} -eq ${_not_found} ]; then
        echo "[Info] Server \"${_service_name}\" not found, stopped."
        return $_failed
    elif [ ${_check} -eq ${_failed} ]; then
        echo "[Error] Server \"${_service_name}\" check failed."
        return $_failed
    fi

    # drop service
    __minecraftctl_remove_service ${_service_name} || _check=$_failed
    if [ ${_check} -eq ${_failed} ]; then
        echo "[Error] Remove Server \"${_service_name}\" failed."
        return $_failed
    fi

    # remove the service volume
    __minecraftctl_remove_volume ${_service_name} || _check=$_failed
    if [ ${_check} -eq ${_failed} ]; then
        echo "[Error] Remove \"${_service_name}\" volume failed."
        return $_failed
    fi

    # remove the world directory
    __minecraftctl_remove_world_directory ${_service_name} || return $_failed
    # remote the service directory
    __minecraftctl_remove_service_directory ${_service_name} || return $_failed

    return $_success
}
