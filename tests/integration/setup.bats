#!/usr/bin/env bats

load '../helpers/common'

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    setup_test_environment
    unset MINECRAFTCTL_CONF MINECRAFTCTL_CONF_FILE MINECRAFTCTL_VAR
    unset MINECRAFTCTL_DEFAULT_IMAGE MINECRAFTCTL_DEFAULT_WORLD
    unset MINECRAFTCTL_BIN MINECRAFTCTL_COMPGENPATH MINECRAFTCTL_JDKPATH
    unset MINECRAFTCTL_SCRIPTPATH MINECRAFTCTL_SERVERPATH
    export BASEROOT="${TEST_ROOT}/install"
    export MINECRAFTCTL_CMD_PATH="${BASEROOT}/bin"
    export MINECRAFTCTL_ETC="${BASEROOT}/etc/minecraftctl"
    export MINECRAFTCTL_COMPGEN_PROFILE="${TEST_ROOT}/profile"
    : > "${MINECRAFTCTL_COMPGEN_PROFILE}"
}

teardown() {
    teardown_test_environment
}

@test "setup installs into an isolated root and registers the command" {
    run bash -c 'cd "$REPO_ROOT" && ./setup.sh'

    [ "$status" -eq 0 ]
    [ -x "${MINECRAFTCTL_CMD_PATH}/minecraftctl" ]
    [ -f "${MINECRAFTCTL_ETC}/minecraftctl.conf" ]
    [ -f "${BASEROOT}/usr/lib/minecraftctl/bin/minecraftctl-create.sh" ]
    [ -f "${BASEROOT}/var/lib/minecraftctl/configs/env/docker-compose.yml" ]
    grep -q "^export MINECRAFTCTL_CONF_FILE=${MINECRAFTCTL_ETC}/minecraftctl.conf$" \
        "${MINECRAFTCTL_COMPGEN_PROFILE}"
    grep -q 'docker build -t minecraftctl_server:latest' "${DOCKER_LOG}"
}
