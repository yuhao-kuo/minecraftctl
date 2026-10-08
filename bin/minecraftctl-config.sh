#!/bin/bash

source "${MINECRAFTCTL_BIN}/minecraftctl_sh_exec.sh"

function minecraftctl_config() {
    local _server_name _file_path

    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "[Error] usage: minecraftctl config <server> [relative-path]"
        return 1
    fi

    _server_name=$1
    if [ $# -eq 2 ]; then
        _file_path=$2
    else
        _file_path=server.properties
    fi

    if [ -z "$_file_path" ]; then
        echo "[Error] file path cannot be empty."
        return 1
    fi

    case "$_file_path" in
        /*|..|../*|*/..|*/../*)
            echo "[Error] file path must stay within the server world directory: ${_file_path}"
            return 1
            ;;
    esac

    __minecraftctl_sh_exec "${_server_name}" vim -- "/opt/mcworld/${_file_path}"
}
