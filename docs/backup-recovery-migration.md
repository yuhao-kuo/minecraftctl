# Backup, recovery, and migration guide

Minecraft worlds are persistent host data. A Docker volume named
`mcctlvol_<name>` binds to
`<MINECRAFTCTL_DEFAULT_WORLD>/<name>`; removing the volume does not remove the
world directory, but `minecraftctl remove` removes both. Keep backups outside
the installation and test that they can be listed and extracted.

## Back up a server

Use a stopped server for a consistent backup. `minecraftctl save` requests an
immediate save, but it does not create a backup and does not freeze writes.

```bash
source "$MINECRAFTCTL_CONF_FILE"
NAME=survival
BACKUP_DIR=/srv/minecraft-backups

minecraftctl stop "$NAME"
mkdir -p "$BACKUP_DIR"
ARCHIVE="${BACKUP_DIR}/${NAME}-$(date +%F-%H%M%S).tar.gz"
tar -C "$MINECRAFTCTL_DEFAULT_WORLD" \
  -czf "$ARCHIVE" "$NAME"
tar -tzf "$ARCHIVE" >/dev/null
minecraftctl start "$NAME"
```

The archive must contain the directory named after the server, including
`level.dat`, region data, and server settings.

Back up the following separately when you need to recreate the installation,
not merely restore a world:

- `<MINECRAFTCTL_VAR>/<name>/server.env` and `docker-volume.yml`
- the Minecraft jar in `MINECRAFTCTL_SERVERPATH`
- the mapped JDK directory in `MINECRAFTCTL_JDKPATH`
- `server_version.conf` in `MINECRAFTCTL_SCRIPTPATH` when it has local changes

Do not keep the only backup beneath `MINECRAFTCTL_DEFAULT_WORLD`; it is
deleted by `minecraftctl remove`.

## Restore a world

Restoring overwrites files in the destination server directory. Keep the
current directory as an additional backup before proceeding.

1. Install `minecraftctl` and make the required Minecraft jar and JDK
   available.
2. Create a stopped server with the same name, port, and Minecraft version:

   ```bash
   minecraftctl create survival 25565 1.21.11
   ```

3. Extract an archive made by this guide into the configured worlds parent:

   ```bash
   source "$MINECRAFTCTL_CONF_FILE"
   tar -C "$MINECRAFTCTL_DEFAULT_WORLD" \
     -xzf /srv/minecraft-backups/survival-2026-01-15-120000.tar.gz
   ```

4. Start the server and inspect its log:

   ```bash
   minecraftctl start survival
   minecraftctl status survival 50
   ```

If the target server already contains a world, stop it and move its directory
to a safe, distinct location before extracting the archive. Never restore an
archive while the target server is running.

## Migrate to another host

Use a new installation on the destination host rather than copying over an
existing installation. The source and destination need compatible CPU
architectures and a JDK that can run on the destination container platform.

1. On the source host, stop the server and create a world archive.
2. Copy the archive to the destination by a transport appropriate for your
   environment. Verify its checksum or list its contents after transfer.
3. Copy or obtain the same Minecraft server jar and a compatible JDK on the
   destination. Ensure the version mapping exists in `server_version.conf`.
4. Install `minecraftctl` into a new location on the destination.
5. Create a server with the same name and Minecraft version, then restore the
   archive as described above.
6. Start it on an unused destination port, verify the log and player data,
   then update DNS, firewall, or port-forwarding rules as needed.

If you changed `server.env` beyond the documented defaults, reproduce those
settings on the destination deliberately. Its paths are installation-specific;
do not copy the file unchanged between hosts with different installation
locations.

## Recover after accidental removal

After `minecraftctl remove` completes, the world directory is gone. Recovery
requires an external backup or storage-level snapshot. If removal failed
part-way, first read [manual server cleanup](remove-cleanup.md), preserve any
remaining world directory, and avoid rerunning `remove` until you know which
resources remain.
