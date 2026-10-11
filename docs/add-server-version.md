# Adding a new Minecraft server version

When Mojang releases a new server version, `minecraftctl` needs two things
on the host before a server of that version can start:

1. the server jar, placed in `MINECRAFTCTL_SERVERPATH`;
2. a line in `server_version.conf` that maps the version to a JDK, and that
   JDK installed in `MINECRAFTCTL_JDKPATH`.

The paths are defined during [installation](install.md). Load them in your shell to use
the commands below:

```bash
source "$MINECRAFTCTL_CONF_FILE"                     # MINECRAFTCTL_VAR, MINECRAFTCTL_CONF, ...
source "${MINECRAFTCTL_CONF}/env/exec.env"            # MINECRAFTCTL_SERVERPATH, JDKPATH, SCRIPTPATH
```

## How a version is resolved

When a container starts, `runtime-scripts/mc.sh` (mounted at
`/opt/mc.conf`) does the following with the server's version (`MCVERSION`):

1. Looks up the JDK directory name in `server_version.conf`.
2. Uses `<MINECRAFTCTL_JDKPATH>/<jdk-directory>/bin/java`.
3. Runs `<MINECRAFTCTL_SERVERPATH>/minecraft_server_v<version>.jar`.

The directories are mounted read-only into the container at `/opt/java`,
`/opt/mcserver` and `/opt/mc.conf`, so changes on the host are visible to
containers without rebuilding the image.

## 1. Add the server jar

Download the server jar from the official Minecraft download page and save it
as `minecraft_server_v<version>.jar`, where `<version>` is exactly the version
you will pass to `minecraftctl create`:

```bash
VERSION=1.21.11     # replace with the new version
cp ~/Downloads/server.jar "${MINECRAFTCTL_SERVERPATH}/minecraft_server_v${VERSION}.jar"
```

The `minecraft_server` prefix comes from the `mojang` entry in
`venders.conf`; servers created by `minecraftctl` use that vendor.

## 2. Make sure the required JDK exists

Each Minecraft version requires a minimum Java version. Check the release
notes of the new version. Current mappings for recent versions are:

| Minecraft versions | JDK directory |
| --- | --- |
| 1.20 – 1.20.4 | `jdk-17.0.8` |
| 1.20.5 – 1.21.11 | `jdk-21.0.3` |
| 26.1 – 26.4 | `jdk-25.0.2` |

If an existing directory in `MINECRAFTCTL_JDKPATH` already satisfies the
requirement, reuse its name. Otherwise, extract a new JDK there. The
directory name is your choice, but it must be used identically in
`server_version.conf`, and the Java binary must exist at `bin/java`:

```bash
mkdir -p "${MINECRAFTCTL_JDKPATH}"
tar -xzf OpenJDK-linux-x64.tar.gz -C "${MINECRAFTCTL_JDKPATH}"
mv "${MINECRAFTCTL_JDKPATH}/<extracted-name>" "${MINECRAFTCTL_JDKPATH}/jdk-21.0.4"
ls "${MINECRAFTCTL_JDKPATH}/jdk-21.0.4/bin/java"
```

The JDK must run on the container's Linux architecture, and its files must be
readable by the container user.

## 3. Update `server_version.conf`

The file is a list of `<minecraft-version>=<jdk-directory>` lines, one per
version, with no spaces:

```text
1.21.11=jdk-21.0.3
26.4=jdk-25.0.2
```

Add a line for the new version:

```bash
echo "1.21.12=jdk-21.0.3" >> "${MINECRAFTCTL_SCRIPTPATH}/server_version.conf"
```

Make sure the file ends with a newline before appending so two entries do not
join on the same line. Keep each version unique.

### Edit the installed copy

Containers read `${MINECRAFTCTL_SCRIPTPATH}/server_version.conf` (the
installed copy, by default `<BASEROOT>/var/lib/minecraftctl/runtime-scripts/`).
The file in the repository's `runtime-scripts/` directory is only copied by
`setup.sh`, and re-running setup is not supported over an existing
installation. Therefore:

- edit the installed copy to use the change immediately; and
- optionally apply the same line to the repository copy so a future
  installation includes it.

Do not use the same path for both; verify with `echo "$MINECRAFTCTL_SCRIPTPATH"`.

### Version lookup uses a regular expression

`mc.sh` looks up the version from the beginning of a line with
`grep "^<version>="`. Therefore, a version is not matched merely because it
is the tail of another version. However, the version is interpolated into a
regular expression, so `.` is treated as a wildcard. Keep each version unique
and confirm that the intended entry is the only matching line:

```bash
grep -Ec '^26\.5=' "${MINECRAFTCTL_SCRIPTPATH}/server_version.conf" # must print 1 after adding
```

## 4. Create and verify a server

```bash
minecraftctl create my-server 25565 1.21.11
minecraftctl start my-server
minecraftctl status my-server
```

On a successful start the log reaches the `Done` line. If it does not, see
the troubleshooting table.

| Symptom in `minecraftctl status` | Cause | Fix |
| --- | --- | --- |
| `Minecraft executable ".../minecraft_server_v<version>.jar" file not found` | Jar missing or misnamed. | Rename or add the jar in `MINECRAFTCTL_SERVERPATH`. |
| `JDK direcotry ".../<jdk>/bin" not found` | Version missing from `server_version.conf`, or JDK directory missing/misnamed. | Add the line, or extract the JDK to `MINECRAFTCTL_JDKPATH`. |
| `Java binary file ".../bin/java" not found` | JDK extracted one level too deep, or incomplete. | Move the JDK contents so `bin/java` is directly inside the named directory. |
| Java version error from the server | JDK is older than the version requires. | Map the version to a newer JDK. |

The error messages above are also appended to `minecraftctl.log` in the
server's world directory.

Changes to `server_version.conf` and the jar directory apply the next time the
container starts, so stop and start an existing server to pick them up:

```bash
minecraftctl stop my-server
minecraftctl start my-server
```

## Checklist

- [ ] `minecraft_server_v<version>.jar` is in `MINECRAFTCTL_SERVERPATH`.
- [ ] A JDK with `bin/java` is in `MINECRAFTCTL_JDKPATH`.
- [ ] `<version>=<jdk-directory>` is in the installed `server_version.conf`.
- [ ] The version appears exactly once and is checked as an exact version.
