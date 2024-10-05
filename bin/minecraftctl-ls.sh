#!/bin/bash

function minecraftctl_ls() {

    docker ps -f "ancestor=minecraftctl_server" -f "status=running" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

}

