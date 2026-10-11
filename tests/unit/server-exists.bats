#!/usr/bin/env bats

load '../helpers/common'

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "server existence check allows an unused name" {
    run_bash_function "${REPO_ROOT}/bin/minecraftctl_check_server_exist.sh" \
        __minecraftctl_check_server_exist "test-server"

    [ "$status" -eq 0 ]
    grep -q 'docker compose ls --all --format json' "${DOCKER_LOG}"
}

@test "server existence check rejects an existing Compose project" {
    export DOCKER_COMPOSE_LS_RESPONSE='[{"Name":"mc_container_test-server"}]'

    run_bash_function "${REPO_ROOT}/bin/minecraftctl_check_server_exist.sh" \
        __minecraftctl_check_server_exist "test-server"

    [ "$status" -eq 1 ]
    [[ "$output" == *'already exists'* ]]
}

@test "server existence check rejects an existing world directory" {
    mkdir -p "${MINECRAFTCTL_DEFAULT_WORLD}/test-server"

    run_bash_function "${REPO_ROOT}/bin/minecraftctl_check_server_exist.sh" \
        __minecraftctl_check_server_exist "test-server"

    [ "$status" -eq 1 ]
    [[ "$output" == *'world directory already exists'* ]]
}

@test "server existence check requires a configured world root" {
    unset MINECRAFTCTL_DEFAULT_WORLD

    run_bash_function "${REPO_ROOT}/bin/minecraftctl_check_server_exist.sh" \
        __minecraftctl_check_server_exist "test-server"

    [ "$status" -eq 1 ]
    [[ "$output" == *'MINECRAFTCTL_DEFAULT_WORLD is not set'* ]]
}

