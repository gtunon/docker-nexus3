# Copyright (c) 2016-present Sonatype, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM       ubuntu:14.04

MAINTAINER Guiomar Tuñon <gtunon@naevatec.com>

USER root 

LABEL vendor=Sonatype \
  com.sonatype.license="Apache License, Version 2.0" \
  com.sonatype.name="Nexus Repository Manager base image"

ARG NEXUS_VERSION=3.2.1-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz
ARG dockergroupid

#pass docker group
RUN echo "**** docker_group_id= $dockergroupid *****" &&\
    groupadd -g $dockergroupid docker

RUN apt-get update \
   && apt-get -y dist-upgrade \
   && apt-get install -y curl \
   && apt-get install -y tar 

# configure java runtime
ENV JAVA_HOME=/opt/java \
  JAVA_VERSION_MAJOR=8 \
  JAVA_VERSION_MINOR=112 \
  JAVA_VERSION_BUILD=15

# configure nexus runtime
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus \
  NEXUS_DATA=/nexus-data \
  NEXUS_CONTEXT='archiva' \
  SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work

# install Oracle JRE
RUN mkdir -p /opt \
  && curl --fail --silent --location --retry 3 \
  --header "Cookie: oraclelicense=accept-securebackup-cookie; " \
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/server-jre-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
  | gunzip \
  | tar -x -C /opt \
  && ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} ${JAVA_HOME}

# install nexus
RUN mkdir -p ${NEXUS_HOME} \
  && curl --fail --silent --location --retry 3 \
    ${NEXUS_DOWNLOAD_URL} \
  | gunzip \
  | tar x -C ${NEXUS_HOME} --strip-components=1 nexus-${NEXUS_VERSION} \
  && chown -R root:root ${NEXUS_HOME}

# configure nexus
RUN sed \
    -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties

#RUN useradd -r \ #system account
#            -u 200 \ #uuid (inside system reserved space)
#            -m \ #create home
#            -c "nexus role account" \ #coment
#            -d ${NEXUS_DATA} \ #home dir
#            -s /bin/false \ #shell
#            -g docker nexus \ #main group an user name

RUN useradd -r -u 200 -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/false -g docker nexus
 
RUN  mkdir -p ${NEXUS_DATA}/etc ${NEXUS_DATA}/log ${NEXUS_DATA}/tmp ${SONATYPE_WORK} \
  && ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3 \
  && chown -R nexus:docker ${NEXUS_DATA}

USER nexus

WORKDIR ${NEXUS_HOME}

ENV JAVA_MAX_MEM=1200m \
  JAVA_MIN_MEM=1200m \
  EXTRA_JAVA_OPTS=""

ENTRYPOINT ["bin/nexus", "run"]