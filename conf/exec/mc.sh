#!/bin/bash


MC_JAVA=`grep "${mc_version}=" /opt/mc.conf/server_version.conf | awk -F'=' '{print $2}'`
JAVA=/opt/mcserver/${MC_JAVA}/bin
export PATH=${PATH}:${JAVA}

MC_EXEC=/opt/mcserver/mcserv/minecraft_server_v${mc_version}.jar

cd /opt/mcworld

EULA_FILE=/opt/mcworld/eula.txt
TEMP_EULA_FILE=/opt/mc.conf/eula_temp.txt

if [ ! -f "$EULA_FILE" ]; then
    if [ -f "$TEMP_EULA_FILE" ]; then
        cp $TEMP_EULA_FILE $EULA_FILE
        _write_eula="sed -e 's/{{\ DATE\ }}/$(date)/g' -i $EULA_FILE"
        eval $_write_eula
    else
        echo "file not found, \"$EULA_FILE\""
    fi
fi

java -Dlog4j2.formatMsgNoLookups=true -Xms${mc_mem_ms} -Xmx${mc_mem_mx} -jar ${MC_EXEC} nogui

