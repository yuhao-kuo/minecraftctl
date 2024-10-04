#!/bin/bash

function minecraftctl_sh() {
    # arg1: server
    # arg2-n: arguments
    docker exec -it $1 /bin/bash 
}
