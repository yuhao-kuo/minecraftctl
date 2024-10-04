#!/bin/bash

function minecraftctl_exec() {
    # arg1: server
    # arg2-n: arguments
    docker exec -it $1 rconclt -c /opt/mc.conf/rcon.conf minecraft ${@:2} 
}
