# Contributing to minecraftctl

## Scope and development model

`minecraftctl` is a Bash and Docker Compose project. Changes should preserve
the separation between the command entry point, `bin/` command scripts,
runtime scripts mounted into containers, and Compose/templates copied by
`setup.sh`.

Keep a change focused. If a user-visible command, installation path, generated
file, or failure mode changes, update the relevant documentation in the same
change.

## Making changes

1. Create a focused branch and make the smallest change that addresses the
   problem.
2. Use portable Bash syntax consistent with the surrounding scripts and quote
   paths and user-provided values.
3. Keep generated installation paths configurable through the existing
   `MINECRAFTCTL_*` variables rather than adding hard-coded locations.
4. Update `README.md` and the affected guide under `docs/` when behaviour,
   requirements, or recovery procedures change.
5. Do not add server jars, JDK distributions, world files, credentials, or
   other generated runtime data to the repository.

## Validating changes

There is no automated test suite or CI configuration in this repository.
Validate the smallest relevant behaviour manually in an isolated Docker host.
At minimum, run Bash syntax checks for modified shell files:

```bash
bash -n setup.sh minecraftctl bin/*.sh runtime-scripts/mc.sh
```

For changes that affect installation or lifecycle commands, test an empty
installation path and confirm the expected `create`, `start`, `status`,
`stop`, and `remove` behaviour. Use a disposable world and port; never use a
production world for validation.

For changes to version support, test that the matching JDK directory, server
jar filename, and `server_version.conf` entry resolve correctly. Update
`docs/add-server-version.md` with any changed procedure.

## Documentation expectations

The README is the documentation entry point. Detailed operational guidance
lives in `docs/`. Keep links relative, commands copyable, and warnings near
destructive or security-sensitive operations. Document supported behaviour;
do not present an internal helper as a supported public command unless it is
intended for users.

## Reporting bugs and proposing changes

Include the command used, its full output, host OS and architecture, Docker
and Compose versions, Minecraft version, and whether Docker `userns-remap` is
enabled. Remove world files, player data, credentials, and private addresses
from reports.
