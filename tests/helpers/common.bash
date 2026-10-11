#!/usr/bin/env bash

setup_test_environment() {
    TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/minecraftctl-tests.XXXXXX")"
    export TEST_ROOT
    export DOCKER_LOG="${TEST_ROOT}/docker.log"
    export DOCKER_COMPOSE_LS_RESPONSE='[]'
    export DOCKER_PS_RESPONSE=''
    export MINECRAFTCTL_CONF="${TEST_ROOT}/config"
    export MINECRAFTCTL_VAR="${TEST_ROOT}/services"
    export MINECRAFTCTL_DEFAULT_WORLD="${TEST_ROOT}/worlds"
    export MINECRAFTCTL_DEFAULT_IMAGE='minecraftctl_server'
    export MINECRAFTCTL_CONF_FILE="${TEST_ROOT}/minecraftctl.conf"
    export PATH="${REPO_ROOT}/tests/fixtures/bin:${PATH}"

    mkdir -p "${MINECRAFTCTL_CONF}/env" "${MINECRAFTCTL_CONF}/templates"
    mkdir -p "${MINECRAFTCTL_VAR}" "${MINECRAFTCTL_DEFAULT_WORLD}"
    : > "${DOCKER_LOG}"
}

teardown_test_environment() {
    rm -rf "${TEST_ROOT}"
}

run_bash_function() {
    local script_path=$1
    shift

    run bash -c 'source "$1"; shift; "$@"' -- "${script_path}" "$@"
}

