
#!/bin/bash


function __minecraftctl_drop_close_service() {

    local _service_name _containers _container_check
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        exit 1
    fi

    _containers=`minecraftctl ps | grep ${_service_name}`
    while IFS= read -r line; do
        _container_check=`echo $line | awk '{print $2}'`
        if [ "${_container_check}" == "${_service_name}" ]; then
            local _runtime
            _runtime=`echo $line | awk '{print $3}'`
            if [ "${_runtime}" == "Up" ]; then
                minecraftctl stop ${_service_name}
            fi
            break
        fi
    done <<< "${_containers}"
}

function __minecraftctl_remove_volume() {

    local _service_name _volume _check_volume_exist
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] remove volume operation failed, the service name is empty."
        exit 1
    fi

    _volume="mcctlvol_${_service_name}"
    _check_volume_exist=`docker volume inspect ${_volume} 2> /dev/null`
    if [ "${_check_volume_exist}" != "[]" ]; then
        docker volume rm ${_volume}
    fi
}

function __minecraftctl_drop_remove_world_directory() {
    local _service_name _default_world _world_dir
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        exit 1
    fi

    _default_world=$MINECRAFTCTL_DEFAULT_WORLD
    _world_dir=`echo "${_default_world}/${_service_name}" | sed 's/\/\//\//g'`

    if [ -d "${_world_dir}" ]; then
        rm -rf "${_world_dir}"
    else
        echo "[Info] the directory \"${_world_dir}\" not fount, continued."
    fi
}

function __minecraftctl_drop_remove_service_directory() {
    local _service_name _var _service_dir
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        exit 1
    fi

    _var=$MINECRAFTCTL_VAR
    _service_dir=`echo "${_var}/${_service_name}" | sed 's/\/\//\//g'`

    if [ -d "${_service_dir}" ]; then
        rm -rf "${_service_dir}"
    else
        echo "[Info] the directory \"${_service_dir}\" not fount, continued."
    fi
}

function minecraftctl_drop_world() {

    local _service_name
    _service_name=$1
    if [ "${_service_name}" == "" ]; then
        echo "[Error] service name is empty."
        exit 1
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
                exit 0
                ;;
            * )
                echo "Invalid input. Please enter y or n."
                ;;
        esac
    done

    # close service
    __minecraftctl_drop_close_service ${_service_name}
    # remove the service volume
    __minecraftctl_remove_volume ${_service_name}
    # remove the world directory
    __minecraftctl_drop_remove_world_directory ${_service_name}
    # remote the service directory
    __minecraftctl_drop_remove_service_directory ${_service_name}
}
