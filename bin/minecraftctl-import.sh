#!/bin/bash


function minecraftctl_import() {
    # arg1: server name
    # arg2: port
    # arg3: server version
    # arg4: import directory path

    local _conf _var _bin _server_name _default_world _default_image _port _version _import_path
    
    _server_name=$1
    _port=$2
    _version=$3
    _import_path=$4

    if [ -d "$_import_path" ]; then
        _conf=$MINECRAFTCTL_CONF
        _var=$MINECRAFTCTL_VAR
        _bin=$MINECRAFTCTL_BIN
        _default_world=$MINECRAFTCTL_DEFAULT_WORLD
        _default_image=$MINECRAFTCTL_DEFAULT_IMAGE
     
        # create config to conf/
        source ${_bin}/minecraftctl_conf_create.sh
        __minecraftctl_conf_create ${_server_name} ${_default_image} ${_port} ${_version} 4G 20G ${_default_world} ${_var} ${_conf}/templates
     
        # import world to container
        source ${_bin}/minecraftctl_data_utils.sh
        __minecraftctl_data_copy ${_server_name} ${_conf} ${_var} H2C ${_import_path} /opt/mcworld
     
        # init world setting
        source ${_bin}/minecraftctl_init.sh
        __minecraftctl_init $_server_name $_conf $_var FALSE

    else
        echo "[Error] Direction \"$_import_path\" not found."
    fi

}

