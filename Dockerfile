FROM alpine:latest
ARG TARGETARCH
ARG GRADLE_DOWNLOAD_SHA256=7ba68c54029790ab444b39d7e293d3236b2632631fb5f2e012bb28b4ff669e4b
ARG LIBERICA_NIK_URL_X64=https://download.bell-sw.com/vm/22.3.0/bellsoft-liberica-vm-openjdk17.0.5+8-22.3.0+2-linux-x64-musl.apk
ARG LIBERICA_NIK_URL_ARM64=https://download.bell-sw.com/vm/22.3.0/bellsoft-liberica-vm-openjdk17.0.5+8-22.3.0+2-linux-aarch64-musl.apk

ARG LIBERICA_NIK_SHA1_X64=46fd47588c4349a8d00363f2065ec0e27b92ebf3
ARG LIBERICA_NIK_SHA1_ARM64=727052a401fa91362a8ff4a2a9c9c3e36ea17598
 
ARG LIBERICA_NIK_FILE=libericai-${TARGETARCH}.apk
 
ENV GRADLE_VERSION 7.6
ENV GRADLE_HOME /opt/gradle
ENV JAVA_HOME /opt/bellsoft/liberica-vm-22.3.0-openjdk17
ENV NIK_HOME ${JAVA_HOME}
ENV GRAALVM_HOME ${JAVA_HOME}

RUN set -o errexit -o nounset\
 && echo "${TARGETARCH}"

RUN set -o errexit -o nounset\
 && apk add --no-cache curl\
 && if [ "${TARGETARCH}" = "amd64" ]; then curl -Lso ${LIBERICA_NIK_FILE} "${LIBERICA_NIK_URL_X64}" && echo "${LIBERICA_NIK_SHA1_X64} *${LIBERICA_NIK_FILE}" | sha1sum -c - ; fi\
 && if [ "${TARGETARCH}" = "arm64" ]; then curl -Lso ${LIBERICA_NIK_FILE} "${LIBERICA_NIK_URL_ARM64}" && echo "${LIBERICA_NIK_SHA1_ARM64} *${LIBERICA_NIK_FILE}" | sha1sum -c - ; fi\
 && apk add --allow-untrusted ${LIBERICA_NIK_FILE}\
 && rm ${LIBERICA_NIK_FILE}\
\
 && addgroup --gid 1000 docker\
 && adduser -S -u 1000 -s /bin/ash docker docker\
 && mkdir -p /home/docker/.gradle\
 && chown -R docker:docker /home/docker\
\
 && curl -Lso gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
 && sha256sum gradle.zip \
 && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c -\
\
 && unzip gradle.zip\
 && rm gradle.zip\
 && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/"\
 && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle\
 && apk add --no-cache ca-certificates openssl\
\
 && gradle --version

USER docker
 
WORKDIR /home/docker
 
CMD ["gradle"]

