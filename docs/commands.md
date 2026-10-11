# minecraftctl command reference

`minecraftctl` manages Minecraft server containers created by this project.
Run commands from a shell where `MINECRAFTCTL_CONF_FILE` points to the
installation configuration file. `setup.sh` configures this automatically for
the installing user; open a new shell or reload the profile file setup
modified (usually `~/.bashrc` for a non-root user).

Docker must be installed and available to the current user. Commands that run
operations inside a server, such as `status`, `exec`, `save`, `users`, `msg`,
`sh`, and `config`, require its container to be running. `start`, `stop`, and
`remove` have their own state requirements.

## Command summary

| Command | Description |
| --- | --- |
| `create` | Create and initialize a new server. |
| `import` | Create a server from an existing world directory. |
| `start` / `stop` | Start or stop a server container. |
| `ls` / `ps` | List running servers or all created server containers. |
| `status` | Show the end of a server's latest log. |
| `exec` | Send an RCON command to a running server. |
| `save` | Request an immediate world save through RCON. |
| `users` | List connected players through RCON. |
| `msg` | Broadcast a message through RCON. |
| `sh` | Start an interactive Bash shell in a running server container. |
| `config` | Edit a file within a server's world directory. |
| `remove` | Remove a stopped server, its world data, and its Docker volume. |

## Creating a server

```text
minecraftctl create <name> <port> <minecraft-version>
```

Example:

```bash
minecraftctl create survival 25565 1.20.1
```

`name` must contain only lowercase letters, digits, underscores (`_`), and
hyphens (`-`). It must start and end with a lowercase letter or digit.

The command creates the world and service configuration, initializes the
server files, enables RCON in `server.properties`, and creates the Docker
container without starting it. During initialization, it opens
`server.properties` in `vim` for configuration. Start the server when setup
is complete:

```bash
minecraftctl start survival
```

## Importing an existing world

```text
minecraftctl import <name> <port> <minecraft-version> <world-directory>
```

Example:

```bash
minecraftctl import survival 25565 1.20.1 /srv/minecraft/survival-world
```

The server-name rules are the same as for `create`. The final argument must
be an existing directory. Its contents are copied into the new server's world
directory, RCON is enabled, and a stopped Docker container is created. Start
the imported server with `minecraftctl start <name>`.

## Starting and stopping servers

```text
minecraftctl start <name>
minecraftctl stop <name>
```

`start` checks that the server world directory, generated service directory,
and `server.env` exist. It also verifies that the pre-created Docker
container uses the image named in `server.env`. If the server was not created
or imported successfully, re-create or import it before starting.

`stop` stops a running server container. If no container with that name is
running, it reports that no running server was found.

## Listing servers

```text
minecraftctl ls
minecraftctl ps
```

`ls` displays running containers built from the configured image. `ps`
displays both running and stopped containers from that image.
Both outputs include the container ID, name, and status.

## Checking server logs

```text
minecraftctl status <name> [line-count]
```

Example:

```bash
minecraftctl status survival 50
```

This prints the last lines of `/opt/mcworld/logs/latest.log` inside the
running container. `line-count` is optional, must be a non-negative integer,
and defaults to `10`.

## Sending server commands

```text
minecraftctl exec <name> <minecraft-command> [arguments...]
```

`exec` sends its remaining arguments to the Minecraft server through the
container's configured RCON client. Do not include a leading slash in the
Minecraft command.

Examples:

```bash
minecraftctl exec survival time set day
minecraftctl exec survival gamerule keepInventory true
minecraftctl exec survival say Server maintenance starts in five minutes.
```

The following shortcuts also use RCON:

```text
minecraftctl save <name>
minecraftctl users <name>
minecraftctl msg <name> <message...>
```

Examples:

```bash
minecraftctl save survival
minecraftctl users survival
minecraftctl msg survival Welcome to the server!
```

`save` sends `save`, `users` sends `list`, and `msg` sends `say` followed by
the supplied message. These commands require the named container to be
running.

## Removing a server

```text
minecraftctl remove <name>
```

The command asks for confirmation and only removes a server that is not
running. It removes the Docker Compose service, its `mcctlvol_<name>` Docker
volume, the server's world directory, and its service configuration directory.
Removing the volume and world directory permanently deletes that server's
world data. Stop the server first with `minecraftctl stop <name>` if it is
running.

If `remove` fails part-way, see
[manual server cleanup](remove-cleanup.md) to finish removing the leftovers.

## Opening a container shell

```text
minecraftctl sh <name>
```

Example:

```bash
minecraftctl sh survival
```

This opens an interactive `/bin/bash` session in the running server
container. Exit the shell normally with `exit`.

## Editing server configuration

```text
minecraftctl config <name> [relative-path]
```

Example:

```bash
minecraftctl config survival
minecraftctl config survival server.properties
```

Without `relative-path`, the command opens
`/opt/mcworld/server.properties` in `vim`. A supplied path is interpreted
relative to `/opt/mcworld`; absolute paths and paths that escape this
directory (such as `../...`) are rejected. The server must be running because
the editor runs inside its container.

## Related operational guides

- [Server defaults and configuration](server-configuration.md) explains the
  generated service settings and supported configuration workflow.
- [Backup, recovery, and migration](backup-recovery-migration.md) describes
  how to protect world data before removal, replacement, or host migration.
- [Troubleshooting](troubleshooting.md) covers installation, container, and
  runtime failures.
