#!/bin/bash


MC_JAVA=`grep "${mc_version}=" /opt/mc.conf/server_version.conf | awk -F'=' '{print $2}'`
MC_VENDER=`grep "${mc_vender}=" /opt/mc.conf/venders.conf | awk -F'=' '{print $2}'`
JAVA=/opt/java/${MC_JAVA}/bin
export PATH=${PATH}:${JAVA}

MC_EXEC=/opt/mcserver/${MC_VENDER}_v${mc_version}.jar

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

if [ ! -f "${MC_EXEC}" ]; then
    echo "[Error] Minecraft executable \"${MC_EXEC}\" file not found"
elif [ ! -d "${JAVA}" ]; then
    echo "[Error] JDK direcotry \"${JAVA}\" not found."
elif [ ! -f "${JAVA%/}/java" ]; then
    echo "[Error] Java binary file \"${JAVA%/}/java\" not found."
else
    java -Dlog4j2.formatMsgNoLookups=true -Xms${mc_mem_ms} -Xmx${mc_mem_mx} -jar ${MC_EXEC} nogui
fi

