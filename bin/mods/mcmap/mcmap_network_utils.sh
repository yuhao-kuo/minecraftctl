#!/bin/bash

function mcmap_network_check() {
    local MCMAP_NETWORK_NAME='mcmap_net'
    local MCMAP_NETWORK_INFO=`docker network ls | grep $MCMAP_NETWORK_NAME`
    local MCMAP_NETWORK_CHECK_RESULT=1
    if [ "$MCMAP_NETWORK_INFO" == "" ]; then
        MCMAP_NETWORK_CHECK_RESULT=0
    fi
    return $MCMAP_NETWORK_CHECK_RESULT
}

function mcmap_network_create() {
    local MCMAP_NETWORK_NAME=$1
    local MCMAP_NETWORK_INFO=`docker network ls | grep $MCMAP_NETWORK_NAME`
    if [ "$MCMAP_NETWORK_INFO" == "" ]; then
        docker network create --driver bridge $MCMAP_NETWORK_NAME
    fi
}

