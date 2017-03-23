#!/bin/sh

set -x

if [ "$1" = 'bin/nexus' ]; then
  pwd
  echo "NEXUS_HOME=${NEXUS_HOME} \n SONATYPE_WORK=${SONATYPE_WORK} \n NEXUS_DATA=${NEXUS_DATA}"

  sed -i 's:^#*[ \t]*nexus-context-path.*:nexus-context-path=/archiva:g' ${NEXUS_HOME}/etc/nexus-default.properties
  sed \
    -e "s|-Xms.*|-Xms${JAVA_MIN_MEM}|g" \
    -e "s|-Xmx.*|-Xmx${JAVA_MAX_MEM}|g" \
    -i "${NEXUS_HOME}/bin/nexus.vmoptions"

  if [ -d "${SONATYPE_WORK}/nexus3" ]; then
    rm -rf "${SONATYPE_WORK}/nexus3"
  fi

  mkdir -p "${NEXUS_DATA}/etc" "${NEXUS_DATA}/log" "${NEXUS_DATA}/tmp" "${SONATYPE_WORK}"
  ln -s "${NEXUS_DATA}" "${SONATYPE_WORK}/nexus3"
  chown -R nexus:docker "${NEXUS_DATA}" "${SONATYPE_WORK}"

fi

exec "$@"
