
#!/bin/bash

source ${MINECRAFTCTL_BIN}/minecraftctl_sh_exec.sh

function minecraftctl_status() {
    # arg1: server name
    # arg2: length (not necessary)
    local _conf _var _server_name _length
    _conf=$MINECRAFTCTL_CONF
    _var=$MINECRAFTCTL_VAR
    _server_name=$1
    _length=$2

    local _success _failed
    _success=0
    _failed=0
    
    # args count check
    local _params_count
    _params_count=1
    if [ $# -lt $_params_count ]; then
        echo "[Error] parameter count $# < $_params_count"
        return ${_failed}
    fi

    # set length default value
    if [ "${_length}" == "" ]; then
        _length=10
    fi

    # length data check
    if ! [[ "${_length}" =~ ^[0-9]+$ ]]; then
        echo "[Error] length \"${_length}\" is not a number."
        return ${_failed}
    fi

    # exec the command
    __minecraftctl_sh_exec "${_server_name}" tail -n "${_length}" /opt/mcworld/logs/latest.log

    return ${_success}
}
