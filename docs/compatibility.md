# Compatibility and host requirements

`minecraftctl` is a Bash-based tool for Linux hosts that run Minecraft in
Docker containers. It has not been documented or tested as a native macOS or
Windows installation.

## Required host software

| Requirement | Why it is needed |
| --- | --- |
| Bash | Runs `setup.sh`, the `minecraftctl` entry point, and command scripts. |
| Docker Engine | Builds the image and runs server containers. The installing user must be permitted to use Docker. |
| Docker Compose v2 | Commands invoke `docker compose`; the legacy `docker-compose` executable is not used. |
| A compatible JDK per Minecraft version | The JDK directories are mounted into containers from the host. |
| Minecraft server jars | The jars are mounted from the host and are not downloaded by setup. |
| `tar` | Required by the documented backup, restore, and migration procedures. |

Use a current Docker Engine and Docker Compose release supported by your Linux
distribution. Confirm the interface is available before setup:

```bash
bash --version
docker version
docker compose version
```

## Platform and architecture

The Docker image is based on `ubuntu:latest`. The Minecraft jar and each JDK
must be runnable for the architecture selected by Docker on the host. Do not
move JDK directories from one CPU architecture to another without obtaining a
compatible build.

The installed JDK needs a `bin/java` executable and must be readable by the
container user. The server jar must use the filename required by the version
guide, such as `minecraft_server_v1.21.11.jar`.

## Docker and filesystem considerations

The game port is published from the container to the host. Select an available
host port and configure firewall or network policy separately; `minecraftctl`
does not do either.

World data is stored on the host through a local bind volume. The configured
world, services, JDK, and jar paths must remain available whenever a server is
started. Network filesystems, removable disks, and storage with weak locking
or unsuitable ownership semantics can cause Docker or Minecraft failures and
should be validated before production use.

When Docker has `userns-remap` enabled, server creation attempts to grant the
remapped user access to the world directory. This path requires `getfacl` and
`setfacl`, as well as suitable `/etc/subuid` and `/etc/subgid` entries. Test a
new server before migrating an important world.

## Interactive use

Initialization and `minecraftctl config` use `vim` inside the container.
Run them from an interactive terminal. The image installed by setup includes
`vim` and the RCON client; they are not required as host packages.
