#!/bin/bash

function minecraftctl_create() {
    # arg1: server name
    # arg2: image name
    # arg3: port
    # arg4: server version
    # arg5: arg world path
    # arg6: output path
    # arg7: template path

    local _server_name _output_path _output_file _input_file _mcworld change_server_name change_image_name change_port change_version change_mcworld

    _server_name=$1

    _output_path=`echo "$6/$_server_name" | sed 's/\/\//\//g'`
    
    if [ ! -d "$_output_path" ]; then
        mkdir -p $_output_path
    fi

    _output_file="${_output_path}/docker-compose.yml"

    if [ -f $_output_file ]; then
        local _time _name
        _time=$(date '+%Y%m%d_%H%M%S')
        _name="${_output_file}.${_time}"
        echo "rename docker-compose.yml to ${_name}"
        mv $_output_file $_name
    fi

    _input_file=$7

    if [ -f $_input_file ]; then
        change_server_name="sed -e 's/{{\ SERVER_NAME\ }}/$1/g' -i $_output_file"
        change_image_name="sed -e 's/{{\ IMAGE_NAME\ }}/$2/g' -i $_output_file"
        change_port="sed -e 's/{{\ PORT\ }}/$3/g' -i $_output_file"
        change_version="sed -e 's/{{\ VERSION\ }}/$4/g' -i $_output_file"
        _mcworld=$(echo $5 | sed 's/\//\\\//g')
        change_mcworld="sed -e 's/{{\ MCWORLD\ }}/$_mcworld/g' -i $_output_file"
        cp $_input_file $_output_file
        eval $change_server_name
        eval $change_image_name
        eval $change_port
        eval $change_version
        eval $change_mcworld
    fi

}
