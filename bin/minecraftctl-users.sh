#!/bin/bash

source ${MINECRAFTCTL_BIN}/minecraftctl-exec.sh

function minecraftctl_users() {
    # arg1 server name
    minecraftctl_exec $1 list
}

