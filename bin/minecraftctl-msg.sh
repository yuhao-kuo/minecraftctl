#!/bin/bash

source minecraftctl-exec.sh

function minecraftctl_msg() {
    # arg1 server name
    minecraftctl_exec $1 say ${@:2}
}

