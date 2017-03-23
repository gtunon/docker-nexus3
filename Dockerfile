FROM ubuntu:14.04

MAINTAINER Guiomar Tuñon <gtunon@naevatec.com>

ARG dockergroupid

USER root

RUN apt-get update -y && \
    apt-get upgrade -y

#pass docker group
RUN echo "**** docker_group_id= $dockergroupid *****" &&\
    groupadd -g $dockergroupid docker


#Install java
RUN apt-get -y install software-properties-common && add-apt-repository ppa:webupd8team/java -y && apt-get update

RUN (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && apt-get install -y oracle-java8-installer oracle-java8-set-default

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH

# configure nexus runtime
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_VERSION="3.2.0-01" \
    NEXUS_HOME="${SONATYPE_DIR}/nexus" \
    NEXUS_DATA="/nexus-data" \
    SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work \
    JAVA_MIN_MEM="1200M" \
    JAVA_MAX_MEM="1200M" \
    JKS_PASSWORD="changeit"

#Install nexus
RUN set -x \
    && apt-get install -y openssl \
    && apt-get install -y tar \
    && apt-get install -y wget\
    && mkdir -p "${SONATYPE_DIR}" \
    && wget -qO - "https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz" \
    | tar -zxC "${SONATYPE_DIR}" \
    && mv "${SONATYPE_DIR}/nexus-${NEXUS_VERSION}" "${NEXUS_HOME}" 

#RUN useradd -r \ #system account
#            -u 200 \ #uuid (inside system reserved space)
#            -m \ #create home
#            -c "nexus role account" \ #coment
#            -d ${NEXUS_DATA} \ #home dir
#            -s /bin/false \ #shell
#            -g docker nexus \ #main group an user name

RUN useradd -r -u 200 -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/false -g docker nexus 

RUN chown -R nexus:docker ${SONATYPE_DIR} \
    &&  chown -R nexus:docker ${SONATYPE_WORK}

WORKDIR "${NEXUS_HOME}"

VOLUME "${NEXUS_DATA}"

COPY docker-entrypoint.sh / 

RUN  chown -R nexus:docker /docker-entrypoint.sh \
     && chmod +x /docker-entrypoint.sh

USER nexus

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bin/nexus", "run"]

