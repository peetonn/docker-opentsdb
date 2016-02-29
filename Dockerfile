FROM java:8-jre
MAINTAINER Jonathon Leight <jonathon.leight@jleight.com>

ENV JAVA_HOME     /usr/lib/jvm/java-8-openjdk-amd64

ENV HBASE_VERSION 1.1.3
ENV HBASE_BASEURL http://apache.org/dist/hbase/stable
ENV HBASE_PACKAGE hbase-${HBASE_VERSION}-bin.tar.gz
ENV HBASE_URL     ${HBASE_BASEURL}/${HBASE_PACKAGE}
ENV HBASE_HOME    /opt/hbase
ENV HBASE_DATA    /var/opt/hbase

ENV OTSDB_VERSION 2.2.0
ENV OTSDB_GITHUB  https://github.com/OpenTSDB/opentsdb
ENV OTSDB_BASEURL ${OTSDB_GITHUB}/releases/download/v${OTSDB_VERSION}
ENV OTSDB_PACKAGE opentsdb-${OTSDB_VERSION}_all.deb
ENV OTSDB_URL     ${OTSDB_BASEURL}/${OTSDB_PACKAGE}
ENV COMPRESSION   NONE

RUN set -x \
  && apt-get update \
  && apt-get install -y \
    curl \
    supervisor \
    gnuplot \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
  && mkdir -p "${HBASE_HOME}" "${HBASE_DATA}" \
  && curl -kL "${HBASE_URL}" | tar -xz -C "${HBASE_HOME}" --strip-components=1 \
  && curl -kL -O "${OTSDB_URL}" \
  && dpkg -i "${OTSDB_PACKAGE}" \
  && rm "${OTSDB_PACKAGE}"

ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf
ADD hbase-service.sh /opt/hbase-service.sh
ADD opentsdb-service.sh /opt/opentsdb-service.sh

EXPOSE 4242
VOLUME ["${HBASE_DATA}"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
