#!/bin/bash


function minecraftctl_create() {
    # arg1: server name
    # arg2: port
    # arg3: server version

    local _conf _var _bin _server_name _default_world _default_image _port _version
    
    _server_name=$1
    _port=$2
    _version=$3
    _conf=$MINECRAFTCTL_CONF
    _var=$MINECRAFTCTL_VAR
    _bin=$MINECRAFTCTL_BIN
    _default_world=$MINECRAFTCTL_DEFAULT_WORLD
    _default_image=$MINECRAFTCTL_DEFAULT_IMAGE

    source ${_bin}/minecraftctl_conf_create.sh

    __minecraftctl_conf_create ${_server_name} ${_default_image} ${_port} ${_version} 4G 20G ${_default_world} ${_var} ${_conf}/templates

    source ${_bin}/minecraftctl_init.sh

    __minecraftctl_init $_server_name $_conf $_var

}

