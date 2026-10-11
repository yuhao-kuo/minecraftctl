# Troubleshooting guide

Run diagnostic commands from a shell that has loaded the installation
configuration:

```bash
echo "$MINECRAFTCTL_CONF_FILE"
source "$MINECRAFTCTL_CONF_FILE"
minecraftctl ps
```

For a server that starts but is not usable, inspect a larger log tail:

```bash
minecraftctl status survival 50
```

## Installation and command issues

| Symptom | Likely cause | Resolution |
| --- | --- | --- |
| `Environment MINECRAFTCTL_CONF_FILE not found.` | A new shell has not loaded the profile entry created by setup. | Open a new shell or source the configured profile file, normally `source ~/.bashrc` for a regular-user installation. |
| `docker: command not found` or Docker connection errors | Docker is absent, stopped, or not available to the current user. | Install and start Docker, then verify `docker version` works without an unexpected privilege change. |
| `docker: 'compose' is not a docker command` | Docker Compose v2 is unavailable. | Install Docker Compose v2; this project invokes `docker compose`, not the legacy executable. |
| Setup stops because a directory exists | Setup does not overwrite an installation. | Do not delete data blindly. Follow the update procedure in [installation](install.md#updating-or-reinstalling), or select a new empty installation path. |
| `minecraftctl: command not found` after regular-user setup | The default command directory is `~/.minecraftctl`, which is not normally on `PATH`. | Add it to `PATH`, or reinstall with `MINECRAFTCTL_CMD_PATH` set to a directory already on `PATH`. |

## Creating or starting a server

| Symptom | Likely cause | Resolution |
| --- | --- | --- |
| A JDK path or Java executable is reported missing | The selected version has no usable JDK mapping or the JDK is not installed as expected. | Check `server_version.conf`, then verify `<jdk-directory>/bin/java` under `MINECRAFTCTL_JDKPATH`. |
| `Minecraft executable ... file not found` | The server jar is missing or has the wrong filename. | Add the jar as `minecraft_server_v<version>.jar` under `MINECRAFTCTL_SERVERPATH`. |
| The server name or world directory already exists | A prior server, failed attempt, or world directory uses the name. | Choose a different name, or inspect and preserve the old data before following [manual cleanup](remove-cleanup.md). |
| Docker reports a port is already allocated | Another process or container uses the selected host port. | Choose an unused port or stop and reconfigure the process that owns it. |
| Initialization times out waiting for `server.properties` | The container failed before Minecraft generated its initial files. | Inspect `docker logs <name>`, then check the server jar, JDK, image, and host filesystem permissions. |
| `docker container ... image ... does not match server.env IMAGE_NAME` | A container was created with a different image setting. | Restore matching service settings or recreate the server from a backup; do not edit the image setting without recreating the container. |

## Runtime and data issues

| Symptom | Likely cause | Resolution |
| --- | --- | --- |
| `status`, `exec`, `save`, `users`, `msg`, `sh`, or `config` says the server is not found | These commands require the named container to be running. | Run `minecraftctl ps`, then start the correct server with `minecraftctl start <name>`. |
| A server exits immediately | The Minecraft process rejected the JDK, jar, or server configuration. | Use `docker logs <name>` and `minecraftctl status <name> 50`; review the version mapping and files described in [adding a server version](add-server-version.md). |
| World files cannot be written | Docker or the container user lacks access to the bind-mounted world directory. | Verify ownership and permissions on the host. If `userns-remap` is enabled, verify ACL tooling and mapping as described in [compatibility](compatibility.md). |
| `remove` failed and resources remain | Removal is intentionally a multi-step process and stops on errors. | Preserve the world directory, then use [manual server cleanup](remove-cleanup.md). |

If a command’s output does not identify the cause, collect its exact output,
the Docker log, the server name, Minecraft version, and the relevant paths
before seeking help. Do not publish worlds, player data, or private network
details in a support request.
