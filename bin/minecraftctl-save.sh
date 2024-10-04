#!/bin/bash

source minecraftctl-exec.sh

function minecraftctl_save() {
    # arg1 server name
    minecraftctl_exec $1 save
}

