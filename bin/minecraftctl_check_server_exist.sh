#!/bin/bash

function __minecraftctl_check_server_exist() {
    local _server_name=$1
    local _success=0
    local _failed=1
    local _project_name _compose_projects _world_dir

    if [ -z "$_server_name" ]; then
        echo "[Error] server name is empty."
        return $_failed
    fi

    if [ -z "$MINECRAFTCTL_DEFAULT_WORLD" ]; then
        echo "[Error] MINECRAFTCTL_DEFAULT_WORLD is not set."
        return $_failed
    fi

    _project_name="mc_container_${_server_name}"
    if ! _compose_projects=$(docker compose ls --all --format json); then
        echo "[Error] failed to check Docker Compose project \"${_project_name}\"."
        return $_failed
    fi

    if printf '%s\n' "$_compose_projects" | grep -Eq "\"Name\"[[:space:]]*:[[:space:]]*\"${_project_name}\""; then
        echo "[Error] Docker Compose project \"${_project_name}\" already exists."
        return $_failed
    fi

    _world_dir="${MINECRAFTCTL_DEFAULT_WORLD%/}/${_server_name}"
    if [ -d "$_world_dir" ]; then
        echo "[Error] server \"${_server_name}\" world directory already exists: ${_world_dir}"
        return $_failed
    fi

    return $_success
}
