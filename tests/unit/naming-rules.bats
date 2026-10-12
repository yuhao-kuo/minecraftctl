#!/usr/bin/env bats

load '../helpers/common'

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    setup_test_environment
}

teardown() {
    teardown_test_environment
}

@test "create accepts valid server names" {
    run_bash_function "${REPO_ROOT}/bin/minecraftctl-create.sh" \
        __minecraftctl_create_naming_rules_check "server_1-name"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "create rejects invalid server names" {
    local name
    for name in '' 'Server' 'server!' '-server' 'server_'; do
        run_bash_function "${REPO_ROOT}/bin/minecraftctl-create.sh" \
            __minecraftctl_create_naming_rules_check "$name"

        [ "$status" -eq 1 ]
        [[ "$output" == *"[Error] name"* ]]
    done
}

@test "import applies the same server naming rules" {
    run_bash_function "${REPO_ROOT}/bin/minecraftctl-import.sh" \
        __minecraftctl_import_naming_rules_check "Server"

    [ "$status" -eq 1 ]
    [[ "$output" == *"must use lowercase letters only"* ]]
}

