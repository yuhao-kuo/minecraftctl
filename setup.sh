#!/bin/bash

function _setup_mkdir() {
    if [ ! -e "$1" ]; then
        mkdir -p $1
    else
        local caller_file="${BASH_SOURCE[1]}"
        local caller_line="${BASH_LINENO[0]}"
        if [ "$2" == "--continue" ]; then
            echo "[Info] directory $1 is exist, continue."
        else
            echo "[Error] ${caller_file}:${caller_line}; $1 existed, stop setup!"
            exit 0
        fi
    fi
}

# setup block

# TODO: minecraftctl depends on Docker, so we need check that.

SHELL_PATH=$(dirname $(readlink -f "$0"))
RUNUSER=$(whoami)

# base root defined
if [[ -z "${BASEROOT:-}" ]]; then
    if [[ "$RUNUSER" == "root" ]]; then
        BASEROOT=""
    else
        BASEROOT="${HOME}/.minecraftctl"
    fi
fi
BASEROOT="${BASEROOT%/}"

if [ "$MINECRAFTCTL_CMD_PATH" == "" ]; then
    if [ "${RUNUSER}" == "root" ]; then
        MINECRAFTCTL_CMD_PATH="/usr/local/bin"
    else
        MINECRAFTCTL_CMD_PATH="${BASEROOT}"
    fi
fi
MINECRAFTCTL_CMD_PATH="${MINECRAFTCTL_CMD_PATH%/}"
_setup_mkdir $MINECRAFTCTL_CMD_PATH --continue

if [ "$MINECRAFTCTL_ETC" == "" ]; then
    MINECRAFTCTL_ETC="${BASEROOT}/etc/minecraftctl"
fi
MINECRAFTCTL_ETC="${MINECRAFTCTL_ETC%/}"
_setup_mkdir $MINECRAFTCTL_ETC

if [ "$MINECRAFTCTL_CONF_FILE" == "" ]; then
    MINECRAFTCTL_CONF_FILE="${MINECRAFTCTL_ETC}/minecraftctl.conf"
fi

if [ "$MINECRAFTCTL_BIN" == "" ]; then
    MINECRAFTCTL_BIN="${BASEROOT}/usr/lib/minecraftctl/bin"
fi
MINECRAFTCTL_BIN="${MINECRAFTCTL_BIN%/}"
_setup_mkdir $MINECRAFTCTL_BIN

if [ "$MINECRAFTCTL_VAR" == "" ]; then
    MINECRAFTCTL_VAR="${BASEROOT}/var/lib/minecraftctl/services"
fi
MINECRAFTCTL_VAR="${MINECRAFTCTL_VAR%/}"
_setup_mkdir $MINECRAFTCTL_VAR

if [ "$MINECRAFTCTL_CONF" == "" ]; then
    MINECRAFTCTL_CONF="${BASEROOT}/var/lib/minecraftctl/configs"
fi
MINECRAFTCTL_CONF="${MINECRAFTCTL_CONF%/}"
_setup_mkdir $MINECRAFTCTL_CONF
_setup_mkdir ${MINECRAFTCTL_CONF}/env
MINECRAFTCTL_ENV_CONF_FILE=${MINECRAFTCTL_CONF}/env/exec.env

if [ "$MINECRAFTCTL_DEFAULT_IMAGE" == "" ]; then
    MINECRAFTCTL_DEFAULT_IMAGE="minecraftctl_server"
fi

if [ "$MINECRAFTCTL_DEFAULT_WORLD" == "" ]; then
    MINECRAFTCTL_DEFAULT_WORLD="${BASEROOT}/var/lib/minecraftctl/worlds"
fi
MINECRAFTCTL_DEFAULT_WORLD="${MINECRAFTCTL_DEFAULT_WORLD%/}"
_setup_mkdir $MINECRAFTCTL_DEFAULT_WORLD

if [ "$MINECRAFTCTL_SERVERPATH" == "" ]; then
    MINECRAFTCTL_SERVERPATH="${BASEROOT}/var/lib/minecraftctl/servers"
fi
MINECRAFTCTL_SERVERPATH="${MINECRAFTCTL_SERVERPATH%/}"
_setup_mkdir $MINECRAFTCTL_SERVERPATH

if [ "$MINECRAFTCTL_JDKPATH" == "" ]; then
    MINECRAFTCTL_JDKPATH="${BASEROOT}/var/lib/minecraftctl/java"
fi
MINECRAFTCTL_JDKPATH="${MINECRAFTCTL_JDKPATH%/}"
_setup_mkdir $MINECRAFTCTL_JDKPATH --continue

if [ "$MINECRAFTCTL_SCRIPTPATH" == "" ]; then
    MINECRAFTCTL_SCRIPTPATH="${BASEROOT}/var/lib/minecraftctl/runtime-scripts"
fi
MINECRAFTCTL_SCRIPTPATH="${MINECRAFTCTL_SCRIPTPATH%/}"
_setup_mkdir $MINECRAFTCTL_SCRIPTPATH

if [ "$MINECRAFTCTL_COMPGENPATH" == "" ]; then
    MINECRAFTCTL_COMPGENPATH="${BASEROOT}/var/lib/minecraftctl/compgen-scripts"
fi
MINECRAFTCTL_COMPGENPATH="${MINECRAFTCTL_COMPGENPATH%/}"
_setup_mkdir $MINECRAFTCTL_COMPGENPATH

# create env setup file
echo "MINECRAFTCTL_BIN=$MINECRAFTCTL_BIN" > ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_VAR=$MINECRAFTCTL_VAR" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_CONF=$MINECRAFTCTL_CONF" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_DEFAULT_IMAGE=$MINECRAFTCTL_DEFAULT_IMAGE" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_DEFAULT_WORLD=$MINECRAFTCTL_DEFAULT_WORLD" >> ${MINECRAFTCTL_CONF_FILE}
echo "MINECRAFTCTL_COMPGENPATH=$MINECRAFTCTL_COMPGENPATH" >> ${MINECRAFTCTL_CONF_FILE}

echo "MINECRAFTCTL_SERVERPATH=$MINECRAFTCTL_SERVERPATH" > ${MINECRAFTCTL_ENV_CONF_FILE}
echo "MINECRAFTCTL_JDKPATH=$MINECRAFTCTL_JDKPATH" >> ${MINECRAFTCTL_ENV_CONF_FILE}
echo "MINECRAFTCTL_SCRIPTPATH=$MINECRAFTCTL_SCRIPTPATH" >> ${MINECRAFTCTL_ENV_CONF_FILE}

# copy data to target
MINECRAFTCTL_MAIN_FILE=$(echo "${MINECRAFTCTL_CMD_PATH}/minecraftctl" | sed 's/\/\//\//g')
cp minecraftctl $MINECRAFTCTL_MAIN_FILE 
chmod 755 $MINECRAFTCTL_MAIN_FILE

cp -R bin/. $MINECRAFTCTL_BIN
cp -R configs/. $MINECRAFTCTL_CONF
cp -R runtime-scripts/. $MINECRAFTCTL_SCRIPTPATH
cp -R compgen-scripts/. $MINECRAFTCTL_COMPGENPATH

# setup shell profile
if [ "${RUNUSER}" == "root" ]; then
    if [ "${MINECRAFTCTL_COMPGEN_PROFILE}" == "" ]; then
        if [ -d "/etc/profile.d" ]; then
            MINECRAFTCTL_COMPGEN_PROFILE="/etc/profile.d/minecraftctl-compgen.sh"
        else
            MINECRAFTCTL_COMPGEN_PROFILE=/etc/profile
        fi
    fi
else
    if [ "${MINECRAFTCTL_COMPGEN_PROFILE}" == "" ]; then
        MINECRAFTCTL_COMPGEN_PROFILE="${HOME}/.bashrc"
    fi
fi

# write minecraftctl env MINECRAFTCTL_CONF_FILE to profile
echo "export MINECRAFTCTL_CONF_FILE=$MINECRAFTCTL_CONF_FILE" >> ${MINECRAFTCTL_COMPGEN_PROFILE}

# register minecraftctl compgen to etc
echo "source ${MINECRAFTCTL_COMPGENPATH}/minecraftctl-sh-prompt" >> ${MINECRAFTCTL_COMPGEN_PROFILE}

# load the new profile
source $MINECRAFTCTL_COMPGEN_PROFILE

# build image
source ${MINECRAFTCTL_BIN}/minecraftctl-buildimage.sh
minecraftctl_buildimage ${MINECRAFTCTL_CONF}/templates/

