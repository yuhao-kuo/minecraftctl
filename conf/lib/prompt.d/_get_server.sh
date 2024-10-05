#!/bin/bash

function _get_servers() {
    local _CONTAINERS _CONFIG _VAR _PARAMETER _SERVERS
    if [ "$1" == "-a" ] || [ "$1" == "--all" ]; then
        _PARAMETER="-a"
    else
        _PARAMETER=""
    fi
    _CONTAINERS=$(docker ps $_PARAMETER --format "{{.Names}}")
    if [ "$_CONTAINERS" == "" ]; then
        echo ""
    else
        _CONFIG="$(dirname $(readlink -f "$0"))/../env/minecraftctl.conf"
        _VAR=$(grep "MINECRAFTCTL_VAR=" $_CONFIG | sed 's/MINECRAFTCTL_VAR=//g')
        #echo `ls -l $_VAR | grep ^d | awk '{print $NF}'`
        _SERVERS=`ls -l $_VAR | grep ^d | awk '{print $NF}'`
        echo $_CONTAINERS | while read -r line; do
            echo $line
        done
    fi
}

