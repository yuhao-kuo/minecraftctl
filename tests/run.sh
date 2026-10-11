#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

bash -n setup.sh minecraftctl bin/*.sh runtime-scripts/mc.sh

if command -v shellcheck >/dev/null 2>&1; then
    shellcheck setup.sh minecraftctl bin/*.sh runtime-scripts/mc.sh
else
    printf '%s\n' '[Info] shellcheck is not installed; skipping ShellCheck.'
fi

if ! command -v bats >/dev/null 2>&1; then
    printf '%s\n' '[Error] bats is required. Install bats-core, then rerun ./tests/run.sh.' >&2
    exit 1
fi

exec bats tests/unit tests/integration

