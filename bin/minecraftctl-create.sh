#!/bin/bash

function __minecraftctl_create_naming_rules_check() {
    local name=$1

    # 允許字元：小寫字母、數字、底線（_）與短橫線（-）。
    # 開頭與結尾：必須以字母或數字開頭與結尾。
    # 大小寫：全部使用小寫。

    if [[ $name =~ [A-Z] ]]; then
        printf '[Error] name "%s" must use lowercase letters only.\n' "$name"
        exit 1
    fi

    if [[ ! $name =~ ^[a-z0-9_-]*$ ]]; then
        printf '[Error] name "%s" may contain only lowercase letters, digits, underscores, and hyphens.\n' "$name"
        exit 1
    fi

    if [[ ! $name =~ ^[a-z0-9]([a-z0-9_-]*[a-z0-9])?$ ]]; then
        printf '[Error] name "%s" must start and end with a lowercase letter or digit.\n' "$name"
        exit 1
    fi
}


function minecraftctl_create() {
    # arg1: server name
    # arg2: port
    # arg3: server version

    local _conf _var _bin _server_name _default_world _default_image _port _version

    local _params_count
    _params_count=3
    if [ $# -lt $_params_count ]; then
        echo "[Error] parameter count $# < $_params_count"
        exit 1
    fi
    
    _server_name=$1
    _port=$2
    _version=$3
    _conf=$MINECRAFTCTL_CONF
    _var=$MINECRAFTCTL_VAR
    _bin=$MINECRAFTCTL_BIN
    _default_world=$MINECRAFTCTL_DEFAULT_WORLD
    _default_image=$MINECRAFTCTL_DEFAULT_IMAGE

    __minecraftctl_create_naming_rules_check $_server_name

    source ${_bin}/minecraftctl_conf_create.sh

    __minecraftctl_conf_create ${_server_name} ${_default_image} ${_port} ${_version} 4G 20G ${_default_world} ${_var} ${_conf}/templates

    source ${_bin}/minecraftctl_init.sh

    __minecraftctl_init $_server_name $_conf $_var

}
