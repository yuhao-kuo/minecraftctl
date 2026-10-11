# Installation, security, and upgrade guide

`setup.sh` installs `minecraftctl`, writes its configuration, registers shell
completion, and builds the Docker image. Run it from the repository root:

```bash
./setup.sh
```

Docker must already be installed (setup does not check this) and usable by the
installing user.

## What setup does

1. Resolves every installation path (see [Configuration variables](#configuration-variables)).
2. Creates the directories. Setup **stops** if a directory it needs to create
   already exists (only the command directory and the JDK directory may
   already exist), so it cannot be re-run over an existing installation
   without removing or relocating the old one first.
3. Writes `minecraftctl.conf` and `configs/env/exec.env`.
4. Copies the `minecraftctl` command, `bin/`, `configs/`, `runtime-scripts/`
   and `compgen-scripts/` into the installation.
5. Appends `export MINECRAFTCTL_CONF_FILE=...` and a `source` line for the
   completion script to the profile file.
6. Loads that profile and builds the Docker image `minecraftctl_server:latest`
   from `<MINECRAFTCTL_CONF>/templates/`.

Setup appends to the profile on every run; remove duplicates manually if you
install again.

## EULA acceptance and security notice

> **Security notice:** `minecraftctl` is intended for a trusted, single-host
> Docker environment. Anyone who can control the host account, its Docker
> daemon, or the server world directory can control the Minecraft server and
> read or modify its data.

Creating a server automatically creates `eula.txt` with `eula=true`. Before
you run `minecraftctl create` or `minecraftctl import`, you must read and
accept the [Minecraft EULA](https://aka.ms/MinecraftEULA). Do not use the tool
if you do not agree to its terms.

RCON is enabled during server initialization so that `exec`, `save`, `users`,
and `msg` can work. The supplied Compose configuration does not publish the
RCON port (`25575`) to the host, and it must remain that way unless you replace
the RCON credentials and deliberately secure network access. Do not expose
RCON directly to an untrusted network.

The Minecraft game port is published on the host port passed to `create` or
`import`. Choose a port that is not already in use and protect the host with
the appropriate firewall rules. Treat world directories, service directories,
JDKs, server jars, and the Docker socket as privileged local resources.

## Directory trees

Setup uses `BASEROOT` as a prefix for most paths. Its default depends on the
user running setup.

### Installed as root

`BASEROOT` is empty, so the files go to the system locations:

```text
/
├── usr/local/bin/
│   └── minecraftctl                      # MINECRAFTCTL_CMD_PATH
├── etc/
│   ├── minecraftctl/                     # MINECRAFTCTL_ETC
│   │   └── minecraftctl.conf             # MINECRAFTCTL_CONF_FILE
│   └── profile.d/
│       └── minecraftctl-compgen.sh       # profile (or /etc/profile if no profile.d)
├── usr/lib/minecraftctl/
│   └── bin/                              # MINECRAFTCTL_BIN (command scripts)
└── var/lib/minecraftctl/
    ├── services/                         # MINECRAFTCTL_VAR, one directory per server
    │   └── <name>/
    │       ├── server.env
    │       └── docker-volume.yml
    ├── configs/                          # MINECRAFTCTL_CONF
    │   ├── env/                          # compose files and exec.env
    │   └── templates/                    # Dockerfile and templates
    ├── worlds/                           # MINECRAFTCTL_DEFAULT_WORLD
    │   └── <name>/                       # one world per server
    ├── servers/                          # MINECRAFTCTL_SERVERPATH (Minecraft server jars)
    ├── java/                             # MINECRAFTCTL_JDKPATH (JDKs)
    ├── runtime-scripts/                  # MINECRAFTCTL_SCRIPTPATH
    └── compgen-scripts/                  # MINECRAFTCTL_COMPGENPATH
```

### Installed as a regular user

`BASEROOT` defaults to `~/.minecraftctl`, and the command is installed in
`BASEROOT` itself. The profile is `~/.bashrc`:

```text
~/
├── .bashrc                               # profile, modified by setup
└── .minecraftctl/                        # BASEROOT
    ├── minecraftctl                      # MINECRAFTCTL_CMD_PATH
    ├── etc/minecraftctl/
    │   └── minecraftctl.conf             # MINECRAFTCTL_CONF_FILE
    ├── usr/lib/minecraftctl/
    │   └── bin/                          # MINECRAFTCTL_BIN
    └── var/lib/minecraftctl/
        ├── services/                     # MINECRAFTCTL_VAR
        ├── configs/                      # MINECRAFTCTL_CONF (env/, templates/)
        ├── worlds/                       # MINECRAFTCTL_DEFAULT_WORLD
        ├── servers/                      # MINECRAFTCTL_SERVERPATH
        ├── java/                         # MINECRAFTCTL_JDKPATH
        ├── runtime-scripts/              # MINECRAFTCTL_SCRIPTPATH
        └── compgen-scripts/              # MINECRAFTCTL_COMPGENPATH
```

For a regular user, `minecraftctl` is not on `PATH` by default. Either add
`~/.minecraftctl` to `PATH` or set `MINECRAFTCTL_CMD_PATH` to a directory that
is already on `PATH` (for example `~/.local/bin`) before running setup.

## Configuration variables

Set variables in the environment before running setup, for example:

```bash
BASEROOT=/srv/minecraftctl \
MINECRAFTCTL_JDKPATH=/opt/jdks \
MINECRAFTCTL_SERVERPATH=/opt/minecraft-servers \
./setup.sh
```

Trailing slashes are removed. Defaults below are shown relative to
`BASEROOT`; for root, `BASEROOT` is empty.

| Variable | Default | Purpose |
| --- | --- | --- |
| `BASEROOT` | root: empty; user: `~/.minecraftctl` | Prefix for the default locations below. |
| `MINECRAFTCTL_CMD_PATH` | root: `/usr/local/bin`; user: `$BASEROOT` | Directory for the `minecraftctl` command. May already exist. |
| `MINECRAFTCTL_ETC` | `$BASEROOT/etc/minecraftctl` | Directory for the configuration file. Must not exist. |
| `MINECRAFTCTL_CONF_FILE` | `$MINECRAFTCTL_ETC/minecraftctl.conf` | Main configuration file; exported to the shell profile. |
| `MINECRAFTCTL_BIN` | `$BASEROOT/usr/lib/minecraftctl/bin` | Command scripts. |
| `MINECRAFTCTL_VAR` | `$BASEROOT/var/lib/minecraftctl/services` | Per-server service files. |
| `MINECRAFTCTL_CONF` | `$BASEROOT/var/lib/minecraftctl/configs` | Compose files and Docker templates. |
| `MINECRAFTCTL_DEFAULT_IMAGE` | `minecraftctl_server` | Docker image name used for new servers and by `ls`/`ps`. |
| `MINECRAFTCTL_DEFAULT_WORLD` | `$BASEROOT/var/lib/minecraftctl/worlds` | Parent directory of server worlds. |
| `MINECRAFTCTL_SERVERPATH` | `$BASEROOT/var/lib/minecraftctl/servers` | Host directory holding Minecraft server jar files. |
| `MINECRAFTCTL_JDKPATH` | `$BASEROOT/var/lib/minecraftctl/java` | Host directory holding Java JDKs. May already exist. |
| `MINECRAFTCTL_SCRIPTPATH` | `$BASEROOT/var/lib/minecraftctl/runtime-scripts` | Scripts and version tables mounted in containers. |
| `MINECRAFTCTL_COMPGENPATH` | `$BASEROOT/var/lib/minecraftctl/compgen-scripts` | Bash completion scripts. |
| `MINECRAFTCTL_COMPGEN_PROFILE` | root: `/etc/profile.d/minecraftctl-compgen.sh` (or `/etc/profile`); user: `~/.bashrc` | Profile file that setup appends to. |

Notes:

- `MINECRAFTCTL_DEFAULT_IMAGE` only changes the name written to the
  configuration. Setup always builds and tags `minecraftctl_server:latest`,
  so keep the default unless you build a matching image yourself.
- Only `MINECRAFTCTL_BIN`, `MINECRAFTCTL_VAR`, `MINECRAFTCTL_CONF`,
  `MINECRAFTCTL_DEFAULT_IMAGE`, `MINECRAFTCTL_DEFAULT_WORLD` and
  `MINECRAFTCTL_COMPGENPATH` are written to `minecraftctl.conf`.
  `MINECRAFTCTL_SERVERPATH`, `MINECRAFTCTL_JDKPATH` and
  `MINECRAFTCTL_SCRIPTPATH` are written to `<MINECRAFTCTL_CONF>/env/exec.env`.

## Providing Minecraft servers and JDKs

Setup creates the server and JDK directories but does not populate them.
Containers mount them read-only at `/opt/mcserver` and `/opt/java`, so add the
files on the host before starting a server.

### Server jar files (`MINECRAFTCTL_SERVERPATH`)

Each jar must be named `<vendor-file>_v<version>.jar`, where the vendor file
prefix comes from `runtime-scripts/venders.conf` (`mojang` →
`minecraft_server`). Servers use `mojang`, so the 1.20.1 server is:

```text
<MINECRAFTCTL_SERVERPATH>/minecraft_server_v1.20.1.jar
```

### JDKs (`MINECRAFTCTL_JDKPATH`)

For each version, `runtime-scripts/server_version.conf` maps the Minecraft
version to a JDK directory name (for example `1.1=jdk-1.8.0_51`). The
directory must contain the JDK, with its binary at:

```text
<MINECRAFTCTL_JDKPATH>/<jdk-directory>/bin/java
```

To support a version that is missing from the table, add a line to
`server_version.conf` in `MINECRAFTCTL_SCRIPTPATH`. See
[adding a server version](add-server-version.md) for the full procedure.

## After setup

Open a new shell, or reload the profile that setup modified:

```bash
source ~/.bashrc   # regular user
```

Then check that the command can find its configuration:

```bash
echo "$MINECRAFTCTL_CONF_FILE"
minecraftctl ls
```

Next, see the [command reference](commands.md) to create a server.

## Updating or reinstalling

`setup.sh` is an installer, not an in-place updater. It stops when most target
directories already exist, and it appends shell-profile entries. Do **not**
rerun it over an existing installation in an attempt to upgrade it.

Before any update or reinstall, create a backup using the
[backup, recovery, and migration guide](backup-recovery-migration.md). In
particular, keep the server worlds, service settings, Minecraft jars, JDKs,
and a copy of the installed configuration.

### Recommended update procedure

1. Stop each server and make a verified backup.
2. Obtain the new project revision in a separate checkout.
3. Install it to a new, empty `BASEROOT` (or a new set of explicitly supplied
   installation paths).
4. Add the required JDK directories and server jars to the new installation.
5. Follow the migration procedure to create servers on the new installation
   and restore their worlds.
6. Start and verify every server before retiring the old installation.

This approach keeps the old installation intact for rollback. When the new
installation is verified, remove the old profile entries manually and archive
or remove the old files only after confirming that all world backups are
usable.

### Reinstalling after an interrupted installation

If setup failed before the image was built, inspect the paths it created before
retrying. Either remove only the incomplete, empty installation directories or
choose a new empty `BASEROOT`; do not delete a directory that may contain a
world. If setup reached the profile-update step, remove duplicate
`MINECRAFTCTL_CONF_FILE` exports and completion `source` lines before trying
again.
