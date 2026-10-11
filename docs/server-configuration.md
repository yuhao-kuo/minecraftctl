# Server defaults and configuration guide

`minecraftctl create` and `minecraftctl import` create a service directory at
`<MINECRAFTCTL_VAR>/<name>` and a world directory at
`<MINECRAFTCTL_DEFAULT_WORLD>/<name>`. The world directory is mounted into the
container at `/opt/mcworld`.

## Defaults created for every server

| Setting | Default | Where it is set |
| --- | --- | --- |
| Server vendor | Mojang | `MCVENDER=mojang` in `server.env` |
| Minimum heap | `4G` | `MCMEMMS` in `server.env` |
| Maximum heap | `20G` | `MCMEMMX` in `server.env` |
| Game port | Value passed to `create` or `import` | `PORT` in `server.env` |
| RCON | Enabled during initialization | `server.properties` |
| EULA | Accepted automatically | `eula.txt` |
| Docker image | `minecraftctl_server:latest` by default | `IMAGE_NAME` in `server.env` |

The image and memory defaults are implementation defaults, not host-capacity
checks. Make sure the host has sufficient memory for the chosen maximum heap
and other running containers.

## Editing Minecraft files

For a running server, use `minecraftctl config` to edit a file inside its
world directory:

```bash
minecraftctl config survival
minecraftctl config survival server.properties
minecraftctl config survival whitelist.json
```

Without a path, it opens `server.properties`. Paths must be relative to the
world directory and cannot escape it. The command opens `vim` in the
container, so save and quit normally with `:wq`.

Settings have different reload behaviour in Minecraft. Restart the server
after changing a setting unless the server documentation explicitly says it
can be reloaded. For player administration, prefer standard Minecraft
commands through `minecraftctl exec` where suitable.

## Service settings

`<MINECRAFTCTL_VAR>/<name>/server.env` records the container name, port,
Minecraft version, image name, world path, Docker volume name, and Java heap
values. It is generated when the server is created. Keep a backup before
editing it.

The current command set has no supported command for changing memory, image,
or port after creation. Changing `server.env` alone does not update an already
created container. To change these values safely, create a backup, create a
replacement server with the desired settings, restore the world, and verify it
before removing the old server. Use an unused name and port while validating
the replacement.

## Version and Java settings

The server version in `server.env` must have a matching
`<version>=<jdk-directory>` entry in
`<MINECRAFTCTL_SCRIPTPATH>/server_version.conf`, a corresponding JDK under
`MINECRAFTCTL_JDKPATH`, and a correctly named server jar under
`MINECRAFTCTL_SERVERPATH`. See [adding a server version](add-server-version.md)
for the required filenames and mapping procedure.

The mounted server jars, JDKs, and runtime scripts are read-only in the
container. Update them on the host, then stop and start the server for the
next launch to use the changed files.
