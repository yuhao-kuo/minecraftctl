#!/bin/bash

source minecraftctl-exec.sh

function minecraftctl_users() {
    # arg1 server name
    minecraftctl_exec $1 list
}

