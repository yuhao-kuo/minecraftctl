# Removing a server manually

`minecraftctl remove <name>` deletes a server in several independent steps.
If it stops part-way, some resources can remain. Because the command reports
`Server "<name>" not found` when Docker Compose no longer has the project
`mc_container_<name>`, running it again will **not** continue with the
volume and directory cleanup. Use this guide to finish the cleanup by hand.

## What `remove` changes

For a server named `<name>`, `remove` runs these steps in order and stops at
the first failure:

| Step | Action | Resource |
| --- | --- | --- |
| 1 | Ask for `y`/`n` confirmation. | None |
| 2 | Look for the Compose project (`docker compose ls -a --filter name=<name>`). If none is found, stop with "not found". If its container is `Up`, stop with "is running". | None |
| 3 | `docker compose ... --project-name mc_container_<name> down` using `<MINECRAFTCTL_CONF>/env/docker-compose.yml`, `<MINECRAFTCTL_VAR>/<name>/docker-volume.yml`, `<MINECRAFTCTL_CONF>/env/exec.env`, and `<MINECRAFTCTL_VAR>/<name>/server.env`. | Docker container `<name>` and the Compose project `mc_container_<name>` |
| 4 | `docker volume rm mcctlvol_<name>`. | Docker volume `mcctlvol_<name>` |
| 5 | `rm -rf <MINECRAFTCTL_DEFAULT_WORLD>/<name>`. | World data on the host |
| 6 | `rm -rf <MINECRAFTCTL_VAR>/<name>`. | Service files on the host |

Notes:

- The volume `mcctlvol_<name>` is a `local` bind volume whose `device` is
  `<MINECRAFTCTL_DEFAULT_WORLD>/<name>`. Removing the volume does **not**
  delete the world files; step 5 does.
- The service directory `<MINECRAFTCTL_VAR>/<name>` holds `server.env`,
  `docker-volume.yml`, any `server.env.<timestamp>` backups, `acl.log`
  (written when Docker `userns-remap` is used), and possibly a leftover
  `copy-source.env`.
- When `userns-remap` is enabled, `create`/`import` add ACL entries to the
  world directory. They are removed together with that directory.
- `remove` does not touch the Docker image (`minecraftctl_server`), the
  global configuration, the Minecraft server and JDK files, or any other
  server.

## Typical partial failures

| Failure point | What remains | Resume from |
| --- | --- | --- |
| Step 3 failed | Container and Compose project | [Step 1](#manual-cleanup) |
| Step 4 failed | Volume, world directory, service directory | [Step 2](#manual-cleanup) |
| Step 5 failed | World directory, service directory | [Step 3](#manual-cleanup) |
| Step 6 failed | Service directory | [Step 4](#manual-cleanup) |
| Container already removed, `remove` says "not found" | Volume, world directory, service directory | [Step 2](#manual-cleanup) |

Unsure where it stopped? Run the inspection commands below; anything they list
still needs to be removed.

## Inspect what is left

```bash
source "$MINECRAFTCTL_CONF_FILE"   # defines MINECRAFTCTL_VAR, MINECRAFTCTL_CONF, ...
NAME=my-server                     # replace with the server name

docker ps -a --filter "label=com.docker.compose.project=mc_container_${NAME}"
docker ps -a --filter "name=init_${NAME}"
docker volume ls --filter "name=mcctlvol_${NAME}"
ls -ld "${MINECRAFTCTL_DEFAULT_WORLD}/${NAME}" "${MINECRAFTCTL_VAR}/${NAME}"
```

## Manual cleanup

Set the variables first. Check that `NAME` is exactly the server name and
that the paths printed are correct before running any `rm -rf`. **Deleting the
world directory permanently destroys the world data; back it up first if you
may need it.**

```bash
source "$MINECRAFTCTL_CONF_FILE"
NAME=my-server

# Refuse an empty or unsafe name, which would make rm -rf hit the wrong path.
[[ $NAME =~ ^[a-z0-9]([a-z0-9_-]*[a-z0-9])?$ ]] || { echo "invalid name"; exit 1; }
echo "${MINECRAFTCTL_DEFAULT_WORLD}/${NAME}"
echo "${MINECRAFTCTL_VAR}/${NAME}"
```

### 1. Remove the container and Compose project

Stop the server first if it is running (`minecraftctl stop "$NAME"`), then
use the Compose files while the service directory still exists:

```bash
docker compose \
  --file "${MINECRAFTCTL_CONF}/env/docker-compose.yml" \
  --file "${MINECRAFTCTL_VAR}/${NAME}/docker-volume.yml" \
  --env-file "${MINECRAFTCTL_CONF}/env/exec.env" \
  --env-file "${MINECRAFTCTL_VAR}/${NAME}/server.env" \
  --project-name "mc_container_${NAME}" down
```

If those files are gone or the command keeps failing, remove the container
directly:

```bash
docker rm -f "$NAME"
```

A leftover initialization container from a failed `create`/`import` may also
exist:

```bash
docker rm -f "init_${NAME}"
```

### 2. Remove the Docker volume

```bash
docker volume rm "mcctlvol_${NAME}"
```

If Docker reports the volume is in use, a container still references it. Find
and remove it:

```bash
docker ps -a --filter "volume=mcctlvol_${NAME}"
```

### 3. Remove the world directory

```bash
rm -rf "${MINECRAFTCTL_DEFAULT_WORLD}/${NAME}"
```

If files are owned by another user (for example with Docker `userns-remap`),
repeat the command with `sudo`.

### 4. Remove the service directory

```bash
rm -rf "${MINECRAFTCTL_VAR}/${NAME}"
```

## Verify

Re-run the inspection commands. Nothing should be listed, and
`minecraftctl ps` should no longer show `<name>`. The name can then be reused
with `minecraftctl create` or `minecraftctl import`, which refuse to continue
while the Compose project or the world directory still exists.
