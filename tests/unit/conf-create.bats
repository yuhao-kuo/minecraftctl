#!/usr/bin/env bats

load '../helpers/common'

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    setup_test_environment
    cp "${REPO_ROOT}/configs/templates/volume.yml.temp" \
        "${MINECRAFTCTL_CONF}/templates/volume.yml.temp"
}

teardown() {
    teardown_test_environment
}

@test "configuration creation writes service files and world directory" {
    run_bash_function "${REPO_ROOT}/bin/minecraftctl_conf_create.sh" \
        __minecraftctl_conf_create "test-server" "minecraftctl_server" "25565" \
        "1.20.1" "4G" "20G" "${MINECRAFTCTL_DEFAULT_WORLD}" \
        "${MINECRAFTCTL_VAR}" "${MINECRAFTCTL_CONF}/templates"

    [ "$status" -eq 0 ]
    [ -d "${MINECRAFTCTL_DEFAULT_WORLD}/test-server" ]
    [ -f "${MINECRAFTCTL_VAR}/test-server/docker-volume.yml" ]
    [ "$(grep '^SERVER_NAME=test-server$' "${MINECRAFTCTL_VAR}/test-server/server.env")" ]
    [ "$(grep '^PORT=25565$' "${MINECRAFTCTL_VAR}/test-server/server.env")" ]
    [ "$(grep '^MCCTLVOL=mcctlvol_test-server$' "${MINECRAFTCTL_VAR}/test-server/server.env")" ]
    grep -q 'mcctlvol_test-server' "${MINECRAFTCTL_VAR}/test-server/docker-volume.yml"
}

@test "configuration creation backs up an existing server environment" {
    mkdir -p "${MINECRAFTCTL_VAR}/test-server"
    printf 'OLD=value\n' > "${MINECRAFTCTL_VAR}/test-server/server.env"

    run_bash_function "${REPO_ROOT}/bin/minecraftctl_conf_create.sh" \
        __minecraftctl_conf_create "test-server" "minecraftctl_server" "25565" \
        "1.20.1" "4G" "20G" "${MINECRAFTCTL_DEFAULT_WORLD}" \
        "${MINECRAFTCTL_VAR}" "${MINECRAFTCTL_CONF}/templates"

    [ "$status" -eq 0 ]
    [ "$(find "${MINECRAFTCTL_VAR}/test-server" -name 'server.env.*' -print -quit)" ]
    [ "$(grep '^SERVER_NAME=test-server$' "${MINECRAFTCTL_VAR}/test-server/server.env")" ]
}

