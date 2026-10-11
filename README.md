# minecraftctl

`minecraftctl` is a Bash-based command-line tool for creating and managing
Docker-hosted Minecraft servers.

## Requirements

- Bash
- Docker, available to the user running `minecraftctl`

## Installation

Clone the repository and run the setup script:

```bash
git clone https://github.com/yuhao-kuo/minecraftctl.git
cd minecraftctl
./setup.sh
```

For a non-root user, setup installs files under `~/.minecraftctl` by default
and adds the command and Bash completion configuration to `~/.bashrc`. For
root, the command defaults to `/usr/local/bin`, and completion is configured
through `/etc/profile.d` when available. Start a new shell, or reload the
profile file setup modified (usually `~/.bashrc` for a non-root user):

```bash
source ~/.bashrc
```

The installation locations can be customized with environment variables such
as `BASEROOT`, `MINECRAFTCTL_CMD_PATH`, and `MINECRAFTCTL_ETC` before running
`setup.sh`. See the [setup guide](docs/setup.md) for the installed directory
trees, all configurable variables, and where to place JDKs and server jars.

## Usage

For a complete reference of every command and its arguments, see the
[command reference](docs/commands.md).

Create a server by providing its name, host port, and Minecraft version:

```bash
minecraftctl create my-server 25565 1.20.1
```

Server names must use lowercase letters, digits, underscores, or hyphens, and
must begin and end with a lowercase letter or digit.

Import an existing world:

```bash
minecraftctl import my-server 25565 1.20.1 /path/to/world
```

Common management commands:

```bash
minecraftctl ls
minecraftctl ps
minecraftctl start my-server
minecraftctl stop my-server
minecraftctl status my-server
minecraftctl save my-server
minecraftctl users my-server
minecraftctl msg my-server
minecraftctl exec my-server <command> [arguments...]
minecraftctl sh my-server
minecraftctl config my-server [relative-path]
```

`minecraftctl config` opens `server.properties` by default. When a
`relative-path` is supplied, it must remain inside the server's world
directory. To remove a stopped server, use `minecraftctl remove my-server`;
this permanently deletes its world data as well as its service files and
Docker volume. See the [command reference](docs/commands.md) for details on
all commands, including image building.

## License

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0)
(Apache-2.0).
