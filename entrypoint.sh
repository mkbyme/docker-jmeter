#!/bin/bash
# Inspired from https://github.com/hhcordero/docker-jmeter-client
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standdard JMeter command parameters.
#

echo "---------------------------------------------------------"
echo "--- PREPARE MOUNT CONFIG (Plugins, Certs, Config      ---"
echo "---------------------------------------------------------"
if [ -d /plugins ] && [ -n "$(ls -A /plugins)" ]
then
    echo "Copied plugin from plugins to $JMETER_HOME/lib/ext"
    for plugin in /plugins/*.jar; do
        cp $plugin $JMETER_HOME/lib/ext
    done;
else
    echo "No plugin or empty at folder '/plugins' to install"
fi

# Install misa sefl-cert.crt available on /certs volume
if [ -d /certs ] && [ -n "$(ls -A /certs)" ]
then
    echo "Trusted cert *.crt from /certs"
    mkdir /usr/local/share/ca-certificates/ -p
    cp /certs/*.crt /usr/local/share/ca-certificates/
    update-ca-certificates
else
    echo "No cert or folder empty at folder '/certs' to trust"
fi

# Copy jmeter user.properties config  available on /home/jmeterconfig volume
if [ -d /home/jmeterconfig ] && [ -n "$(ls -A /home/jmeterconfig)" ]
then
    echo "Copied jmeter config from /home/jmeterconfig to $JMETER_BIN"
    cp /home/jmeterconfig/*.properties $JMETER_BIN
else
    echo "No config or empty at folder '/home/jmeterconfig' to config jmeter at $JMETER_BIN"
fi

echo "---------------------------------------------------------"
echo "--- PREPARE MOUNT CONFIG (Plugins, Certs, Config) END ---"
echo "---------------------------------------------------------"

# Execute JMeter command
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

# Keep entrypoint simple: we must pass the standard JMeter arguments
EXTRA_ARGS=-Dlog4j2.formatMsgNoLookups=true
echo "jmeter ALL ARGS=${EXTRA_ARGS} $@"
jmeter ${EXTRA_ARGS} $@

echo "END Running Jmeter on `date`"

#     -n \
#    -t "/tests/${TEST_DIR}/${TEST_PLAN}.jmx" \
#    -l "/tests/${TEST_DIR}/${TEST_PLAN}.jtl"
# exec tail -f jmeter.log
#    -D "java.rmi.server.hostname=${IP}" \
#    -D "client.rmi.localport=${RMI_PORT}" \
#  -R $REMOTE_HOSTS