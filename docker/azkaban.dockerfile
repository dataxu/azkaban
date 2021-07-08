
FROM docker-dev.artifactory.tools.roku.com/ruby:2.3

#
# Java install, taken from here:
# https://github.com/AdoptOpenJDK/openjdk-docker/blob/master/8/jdk/debian/Dockerfile.hotspot.releases.full
#
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8

ENV JAVA_VERSION jdk8u282-b08

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       ppc64el|ppc64le) \
         ESUM='d69bd545691058b55337d2a5eb1092880a5cab0753ede4d82b181242aac8a8fe'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u282-b08/OpenJDK8U-jdk_ppc64le_linux_hotspot_8u282b08.tar.gz'; \
         ;; \
       s390x) \
         ESUM='040cde56788a803a6972af9e5d4985dbb8d698e6691c3aa0edfc765e91aeea33'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u282-b08/OpenJDK8U-jdk_s390x_linux_hotspot_8u282b08.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='e6e6e0356649b9696fa5082cfcb0663d4bef159fc22d406e3a012e71fce83a5c'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u282-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u282b08.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
#
# End of Java install
#


#
# Azkaban install
#
WORKDIR /
COPY azkaban /azkaban

RUN chmod +x /azkaban/docker/azkaban.sh
RUN /azkaban/docker/azkaban.sh

COPY azkaban/docker/azkaban.properties /azkaban/azkaban-web-server/build/install/azkaban-web-server/conf/azkaban.properties
COPY azkaban/docker/azkaban.properties /azkaban/azkaban-exec-server/build/install/azkaban-exec-server/conf/azkaban.properties

EXPOSE 8081
EXPOSE 12321