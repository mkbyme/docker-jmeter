# inspired by https://github.com/hauptmedia/docker-jmeter  and
# https://github.com/hhcordero/docker-jmeter-server/blob/master/Dockerfile
# clone from https://github.com/justb4/docker-jmeter
# Stage 1: download và giải nén JMeter
FROM alpine:3.22.1 AS downloader
ARG JMETER_VERSION="5.6.3"
ENV JMETER_DOWNLOAD_URL=https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
RUN apk add --no-cache curl tar && \
    mkdir -p /tmp/jmeter && \
    curl -L --silent ${JMETER_DOWNLOAD_URL} -o /tmp/jmeter/apache-jmeter-${JMETER_VERSION}.tgz && \
    mkdir -p /opt && \
    tar -xzf /tmp/jmeter/apache-jmeter-${JMETER_VERSION}.tgz -C /opt

# Stage 2: final image
FROM alpine:3.22.1
ARG JMETER_VERSION="5.6.3"
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN=${JMETER_HOME}/bin
ENV TZ="Asia/Ho_Chi_Minh"
RUN apk add --no-cache \
        ca-certificates \
        openjdk17-jre \
        tzdata \
        curl \
        unzip \
        bash \
        nss && \
    update-ca-certificates
# Copy JMeter đã giải nén từ stage downloader
COPY --from=downloader /opt/apache-jmeter-${JMETER_VERSION} /opt/apache-jmeter-${JMETER_VERSION}
ENV PATH=$PATH:$JMETER_BIN
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
WORKDIR ${JMETER_HOME}
ENTRYPOINT ["/entrypoint.sh"]