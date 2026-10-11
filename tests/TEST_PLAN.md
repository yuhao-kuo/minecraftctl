# Test Plan

## Goals

The test suite protects command validation, generated configuration, Docker
command construction, and isolated installation behavior without using a real
Minecraft world or Docker daemon in the default test run.

## Test levels

### Fast checks

Run these for every change:

```bash
./tests/run.sh
```

The runner performs Bash syntax validation, ShellCheck when it is installed,
and all Bats unit and isolated-installation tests. Bats tests use the fake
`docker` executable in `tests/fixtures/bin/`, so they neither create Docker
resources nor modify the user's shell profile.

### Docker end-to-end tests

Future end-to-end tests belong in `tests/e2e/`. They must use a unique server
name, a temporary `BASEROOT`, an unused port, and a cleanup trap. They should
exercise `create`, `start`, `status`, `stop`, and `remove` against a real
Docker daemon. Because they require JDKs, server artifacts, and a Docker host,
they are intentionally excluded from the default test runner.

## Initial coverage

| Area | Test file | Covered behavior |
| --- | --- | --- |
| Server names | `unit/naming-rules.bats` | Accepted names and rejected empty, uppercase, malformed, and edge-delimiter names |
| Service configuration | `unit/conf-create.bats` | Generated `server.env`, volume YAML, world directory, and backup behavior |
| Server existence | `unit/server-exists.bats` | Docker Compose project collisions, world collisions, Docker errors, and unset configuration |
| Start command | `unit/start.bats` | File prerequisites, image matching, and Compose invocation |
| Installation | `integration/setup.bats` | Installation into a temporary root, copied assets, generated configuration, profile registration, and image build invocation |

## Conventions

- Keep tests deterministic and self-cleaning through `setup_test_environment`
  and `teardown_test_environment`.
- Test reusable functions in a subprocess when they call `exit`; assert both
  their exit status and user-facing error text.
- Add fake-Docker behavior only when a test needs it. Record invocations in
  `DOCKER_LOG` and assert arguments rather than running containers.
- New command behavior requires a focused unit test. Docker lifecycle changes
  also require an end-to-end test when a disposable Docker environment is
  available.

