#!/bin/bash

function _setup_mkdir() {
    if [ -d "$1" ]; then
        mkdir -p $1
    fi
}

# setup block

SHELL_PATH=$(dirname $(readlink -f "$0"))


if [ "$MINECRAFTCTL_CMD_PATH" == "" ]; then
    MINECRAFTCTL_CMD_PATH="/usr/local/bin"
fi
_setup_mkdir $MINECRAFTCTL_CMD_PATH

if [ "$MINECRAFTCTL_ETC" == "" ]; then
    MINECRAFTCTL_ETC="/etc/minecraftctl"
fi
_setup_mkdir $MINECRAFTCTL_ETC

if [ "$MINECRAFTCTL_CONF_FILE" == "" ]; then
    MINECRAFTCTL_CONF_FILE="${MINECRAFTCTL_ETC}/minecraftctl.conf"
fi

if [ "$MINECRAFTCTL_BIN" == "" ]; then
    MINECRAFTCTL_BIN="/usr/lib/minecraftctl/bin"
fi
_setup_mkdir $MINECRAFTCTL_BIN

if [ "$MINECRAFTCTL_VAR" == "" ]; then
    MINECRAFTCTL_VAR="/var/lib/minecraftctl/services"
fi
_setup_mkdir $MINECRAFTCTL_VAR

if [ "$MINECRAFTCTL_CONF" == "" ]; then
    MINECRAFTCTL_CONF="/var/lib/minecraftctl/configs"
fi
_setup_mkdir $MINECRAFTCTL_CONF

if [ "$MINECRAFTCTL_DEFAULT_IMAGE" == "" ]; then
    MINECRAFTCTL_DEFAULT_IMAGE="minecraftctl_server"
fi
_setup_mkdir $MINECRAFTCTL_DEFAULT_IMAGE

if [ "$MINECRAFTCTL_DEFAULT_WORLD" == "" ]; then
    MINECRAFTCTL_DEFAULT_WORLD="/var/lib/minecraftctl/worlds"
fi
_setup_mkdir $MINECRAFTCTL_DEFAULT_WORLD

if [ "$MINECRAFTCTL_SERVERPATH" == "" ]; then
    MINECRAFTCTL_SERVERPATH="/var/lib/minecraftctl/servers"
fi
_setup_mkdir $MINECRAFTCTL_SERVERPATH

if [ "$MINECRAFTCTL_SCRIPTPATH" == "" ]; then
    MINECRAFTCTL_SCRIPTPATH="/var/lib/minecraftctl/runtime-scripts"
fi
_setup_mkdir $MINECRAFTCTL_SCRIPTPATH

if [ "$MINECRAFTCTL_COMPGENPATH" == "" ]; then
    MINECRAFTCTL_COMPGENPATH="/var/lib/minecraftctl/compgen-scripts"
fi
_setup_mkdir $MINECRAFTCTL_COMPGENPATH

# create env setup file
echo "MINECRAFTCTL_BIN=$MINECRAFTCTL_BIN" > ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_VAR=$MINECRAFTCTL_VAR" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_CONF=$MINECRAFTCTL_CONF" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_DEFAULT_IMAGE=$MINECRAFTCTL_DEFAULT_IMAGE" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_DEFAULT_WORLD=$MINECRAFTCTL_DEFAULT_WORLD" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_SERVERPATH=$MINECRAFTCTL_SERVERPATH" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_SCRIPTPATH=$MINECRAFTCTL_SCRIPTPATH" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_COMPGENPATH=$MINECRAFTCTL_COMPGENPATH" >> ${MINECRAFTCTL_CONF_FILE}

# copy data to target
cp minecraftctl $(echo "${MINECRAFTCTL_CMD_PATH}/minecraftctl" | sed 's/\/\//\//g')

cp -R bin/. $MINECRAFTCTL_BIN
cp -R conf/. $MINECRAFTCTL_CONF
cp -R runtime-scripts/. $MINECRAFTCTL_SCRIPTPATH
cp -R compgen-scripts/. $MINECRAFTCTL_COMPGENPATH

# TODO: need create server java and minecraft jar direction and print how to setup.

# write minecraftctl env MINECRAFTCTL_CONF_FILE to profile
echo "MINECRAFTCTL_CONF_FILE=$MINECRAFTCTL_CONF_FILE" >> /etc/profile

# register minecraftctl compgen to etc
echo "source $MINECRAFTCTL_COMPGENPATH" >> /etc/profile
source $MINECRAFTCTL_COMPGENPATH

