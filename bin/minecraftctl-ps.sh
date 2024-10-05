#!/bin/bash

function minecraftctl_ps() {

    docker ps -a -f "ancestor=minecraftctl_server" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

}

