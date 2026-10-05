#!/bin/bash


function minecraftctl_start() {
    # arg1: conf path
    # arg2: var path
    # arg3: server name

    local _conf _var _server_name _docker_main_yml _docker_volume_yml _exec_env _server_env

    local _params_count
    _params_count=1
    if [ $# -lt $_params_count ]; then
        echo "[Error] parameter count $# < $_params_count"
        exit 1
    fi

    _conf=$MINECRAFTCTL_CONF
    _var=$MINECRAFTCTL_VAR
    _server_name=$1

    # _server_name check
    local _world_dir _service_dir _server_env_file _image_name _container_images _container_image _image_matched

    _world_dir=`echo "${MINECRAFTCTL_DEFAULT_WORLD}/${_server_name}" | sed 's/\/\//\//g'`
    if [ ! -d "$_world_dir" ]; then
        echo "[Error] server \"${_server_name}\" world directory not found: ${_world_dir}"
        exit 1
    fi

    _service_dir=`echo "${_var}/${_server_name}" | sed 's/\/\//\//g'`
    if [ ! -d "$_service_dir" ]; then
        echo "[Error] server \"${_server_name}\" service file directory not found: ${_service_dir}"
        exit 1
    fi

    _server_env_file="${_service_dir}/server.env"
    if [ ! -f "$_server_env_file" ]; then
        echo "[Error] server \"${_server_name}\" server.env not found: ${_server_env_file}"
        exit 1
    fi

    _image_name=`grep '^IMAGE_NAME=' "$_server_env_file" | tail -n 1 | cut -d '=' -f 2-`
    if [ "$_image_name" == "" ]; then
        echo "[Error] IMAGE_NAME is not set in ${_server_env_file}"
        exit 1
    fi

    # the compose project name is mc_container_${_server_name}
    _container_images=`docker ps -a --filter "label=com.docker.compose.project=mc_container_${_server_name}" --format "{{.Image}}" 2>/dev/null`
    if [ "$_container_images" == "" ]; then
        echo "[Error] docker container \"mc_container_${_server_name}\" not found"
        exit 1
    fi

    _image_matched=0
    while IFS= read -r _container_image; do
        if [ "$_container_image" == "$_image_name" ] || [ "$_container_image" == "${_image_name}:latest" ]; then
            _image_matched=1
            break
        fi
    done <<< "$_container_images"
    if [ $_image_matched -ne 1 ]; then
        echo "[Error] docker container \"mc_container_${_server_name}\" image \"${_container_images}\" does not match server.env IMAGE_NAME \"${_image_name}\""
        exit 1
    fi

    # build container config file paths
    _docker_main_yml=`echo "${_conf}/env/docker-compose.yml" | sed 's/\/\//\//g'`
    _docker_volume_yml=`echo "${_var}/${_server_name}/docker-volume.yml" | sed 's/\/\//\//g'`
    _exec_env=`echo "${_conf}/env/exec.env" | sed 's/\/\//\//g'`
    _server_env=`echo "${_var}/${_server_name}/server.env" | sed 's/\/\//\//g'`

    # container start
    docker compose --file ${_docker_main_yml} --file ${_docker_volume_yml} --env-file ${_exec_env} --env-file ${_server_env} --project-name "mc_container_${_server_name}" start

}

