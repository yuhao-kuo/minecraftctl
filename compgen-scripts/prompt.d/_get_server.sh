#!/bin/bash

function _get_servers() {
    local _CONTAINERS _CONFIG _VAR _PARAMETER _SERVERS
    if [ "$2" == "-a" ] || [ "$2" == "--all" ]; then
        _PARAMETER="-a"
    else
        _PARAMETER=""
    fi
    _CONTAINERS=$(docker ps $_PARAMETER --format "{{.Names}}")
    if [ "$_CONTAINERS" == "" ]; then
        echo ""
    else
        _CONFIG="${MINECRAFTCTL_CONF_FILE}"
        _VAR=$(grep "MINECRAFTCTL_VAR=" $_CONFIG | sed 's/MINECRAFTCTL_VAR=//g')
        _SERVERS=`ls -l $_VAR | grep ^d | awk '{print $NF}'`
        while IFS= read -r line; do
            if grep -Fxq -- "$line" <<< "$_SERVERS"; then
                printf '%s\n' "$line"
            fi
        done <<< "$_CONTAINERS"
    fi
}
