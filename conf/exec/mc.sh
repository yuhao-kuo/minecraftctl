#!/bin/bash


MC_JAVA=`grep "${mc_version}=" /opt/mc.conf/server_version.conf | awk -F'=' '{print $2}'`
JAVA=/opt/mcserver/${MC_JAVA}/bin
export PATH=${PATH}:${JAVA}

MC_EXEC=/opt/mcserver/mcserv/minecraft_server_v${mc_version}.jar

cd /opt/mcworld

java -Dlog4j2.formatMsgNoLookups=true -Xms${mc_mem_ms} -Xmx${mc_mem_mx} -jar ${MC_EXEC} nogui

