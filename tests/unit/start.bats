#!/usr/bin/env bats

load '../helpers/common'

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    setup_test_environment
    mkdir -p "${MINECRAFTCTL_DEFAULT_WORLD}/test-server"
    mkdir -p "${MINECRAFTCTL_VAR}/test-server"
    : > "${MINECRAFTCTL_CONF}/env/docker-compose.yml"
    : > "${MINECRAFTCTL_CONF}/env/exec.env"
    : > "${MINECRAFTCTL_VAR}/test-server/docker-volume.yml"
    printf 'IMAGE_NAME=minecraftctl_server\n' \
        > "${MINECRAFTCTL_VAR}/test-server/server.env"
}

teardown() {
    teardown_test_environment
}

@test "start invokes Docker Compose for a matching container image" {
    export DOCKER_PS_RESPONSE='minecraftctl_server:latest'

    run_bash_function "${REPO_ROOT}/bin/minecraftctl-start.sh" \
        minecraftctl_start "test-server"

    [ "$status" -eq 0 ]
    grep -q -- '--project-name mc_container_test-server start' "${DOCKER_LOG}"
}

@test "start rejects a mismatched container image" {
    export DOCKER_PS_RESPONSE='another-image:latest'

    run_bash_function "${REPO_ROOT}/bin/minecraftctl-start.sh" \
        minecraftctl_start "test-server"

    [ "$status" -eq 1 ]
    [[ "$output" == *'does not match server.env IMAGE_NAME'* ]]
}

@test "start rejects a missing world directory" {
    rm -rf "${MINECRAFTCTL_DEFAULT_WORLD}/test-server"

    run_bash_function "${REPO_ROOT}/bin/minecraftctl-start.sh" \
        minecraftctl_start "test-server"

    [ "$status" -eq 1 ]
    [[ "$output" == *'world directory not found'* ]]
}

