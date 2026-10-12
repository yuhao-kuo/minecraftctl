#!/bin/bash

function __minecraftctl_check_server_jdk_depend() {
    local _success _failed
    _success=0
    _failed=1

    local _conf _script _version_check _jdk_version
    _conf=$MINECRAFTCTL_CONF
    _jdk_version=$1

    if [ ! -f "${_conf}/env/exec.env" ]; then
        echo "[Error] exec.env not found, path: \"${_conf}\""
        return $_failed
    fi

    _script=$(grep '^MINECRAFTCTL_SCRIPTPATH=' "${_conf}"/env/exec.env | cut -d '=' -f 2)

    if [ ! -f "${_script}/server_version.conf" ]; then
        echo "[Error] server_version.conf not found, on path: \"${_script}\""
        return $_failed
    fi
    _version_check=$(grep "^${_jdk_version}" "${_script}"/server_version.conf | cut -d '=' -f 2)

    if [ "${_version_check}" == "" ]; then
        echo "[Error] server config not defined JDK version."
        return $_failed
    fi

    local _jdk_dir
    _jdk_dir=$(grep '^MINECRAFTCTL_JDKPATH=' "${_conf}"/env/exec.env | cut -d '=' -f 2)
    if [ ! -d "${_jdk_dir}" ]; then
        echo "[Error] JDK path not found: ${_jdk_dir}"
        return $_failed
    fi

    if [ ! -d "${_jdk_dir}/${_version_check}/bin" ]; then
        echo "[Error] JDK path not found: ${_jdk_dir}/${_version_check}/bin"
        return $_failed
    fi

    if [ ! -f "${_jdk_dir}/${_version_check}/bin/java" ]; then
        echo "[Error] Java executable not found: ${_jdk_dir}/${_version_check}/bin/java"
        return $_failed
    fi

    return $_success
}

function __minecraftctl_jdk_check() {
    local _success _failed _result
    _success=0
    _failed=1
    _result=${_success}

    local _jdk_version=$1

    if [ "${_jdk_version}" == "" ]; then
        return $_failed
    fi

    __minecraftctl_check_server_jdk_depend "$_jdk_version" || _result=$_failed

    return $_result
}
