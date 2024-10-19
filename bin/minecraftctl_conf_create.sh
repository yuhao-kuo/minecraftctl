#!/bin/bash

function __minecraftctl_conf_create_is_remap() {
    # arg1: world path
    # arg2: config path

    local _world_path _docker_remap_user _subuid _subgid _log _conf_dir

    _world_path=$1
    _conf_dir=$2
    _docker_remap_user=`cat /etc/docker/daemon.json | grep '"userns-remap"' | sed s/\"//g | awk '{print $2}'`

    # change world account
    if [ "$_docker_remap_user" != "" ]; then

        # if use docker default, change the variable
        if [ "$_docker_remap_user" == "default" ]; then
            _docker_remap_user="dockremap"
        fi

        # add ACL for container user account
        _subuid=`cat /etc/subuid | grep $_docker_remap_user | awk -F':' '{print $2}'`
        _subgid=`cat /etc/subgid | grep $_docker_remap_user | awk -F':' '{print $2}'`
        _subuid=`expr $_subuid + 1000`
        _subgid=`expr $_subgid + 1000`
        _log=`echo "$_conf_dir/acl.log" | sed 's/\/\//\//g'`
        getfacl -p $_world_path >> $_log
        chmod 600 $_log
        setfacl -m u:${_subuid}:rwx ${_world_path}
        setfacl -m g:${_subgid}:rwx ${_world_path}
    fi
}

function __minecraftctl_conf_create_world() {
    # arg1: world path
    # arg2: template file direction
    # arg3: server config direction

    local _world_dir _eula_file _eula_template_file _write_eula _conf_dir
    _world_dir=$1
    _conf_dir=$3

#    _eula_file=`echo "$_world_dir/eula.txt" | sed 's/\/\//\//g'`
#    _eula_template_file=`echo "$2/eula.txt.temp" | sed 's/\/\//\//g'`

    if [ ! -d "$_world_dir" ]; then
        mkdir -p $_world_dir
    fi
 
#    # eula
#    if [ ! -f "$_eula_file" ]; then
#        if [ -f "$_eula_template_file" ]; then
#            cp $_eula_template_file $_eula_file
#            _write_eula="sed -e 's/{{\ DATE\ }}/$(date)/g' -i $_eula_file"
#            eval $_write_eula
#        else
#            echo "file not found, \"$_eula_file\""
#        fi
#    fi

    # change owner of world
    __minecraftctl_conf_create_is_remap $_world_dir $_conf_dir
}

function __minecraftctl_conf_create() {
    # arg1: server name
    # arg2: image name
    # arg3: port
    # arg4: server version
    # arg5: memory min
    # arg6: memory max
    # arg7: arg world path *
    # arg8: output path *
    # arg9: template path *

    local _server_name _output_path _output_file _input_dir _input_file _mcworld _mcvol_name _start_setup

    _server_name=$1

    _output_path=`echo "$8/$_server_name" | sed 's/\/\//\//g'`

    _start_setup=0
    if [ ! -d "$_output_path" ]; then
        mkdir -p $_output_path
        _start_setup=1
    fi

    _output_file="${_output_path}/server.env"

    if [ -f $_output_file ]; then
        local _time _name
        _time=$(date '+%Y%m%d_%H%M%S')
        _name="${_output_file}.${_time}"
        echo "rename server.env to ${_name}"
        mv $_output_file $_name
    fi

    echo "SERVER_NAME=$_server_name" >> $_output_file
    echo "IMAGE_NAME=$2" >> $_output_file
    echo "PORT=$3" >> $_output_file
    echo "MCVERSION=$4" >> $_output_file
    echo "MCWORLD=$7/$_server_name" >> $_output_file

    _input_dir=$9
    _mcvol_name="mcctlvol_${_server_name}"
    __minecraftctl_conf_create_world "$7/$_server_name" $_input_dir $_output_path

    cat $_input_dir/volume.yml.temp | sed "s/{{\ MCCTLVOL\ }}/${_mcvol_name}/g" > $_output_path/docker-volume.yml

    echo "MCCTLVOL=${_mcvol_name}" >> $_output_file
    echo "VOLYML=$_output_path/docker-volume.yml" >> $_output_file

    echo "MCMEMMS=$5" >> $_output_file
    echo "MCMEMMX=$6" >> $_output_file

}

