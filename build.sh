#!/bin/bash

JMETER_VERSION=${JMETER_VERSION:-"5.6.3"}
IMAGE_TIMEZONE=${IMAGE_TIMEZONE:-"Asia/Ho_Chi_Minh"}

# Example build line
docker build  --build-arg JMETER_VERSION=${JMETER_VERSION} --build-arg TZ=${IMAGE_TIMEZONE} -t "mkbyme/docker-jmeter:${JMETER_VERSION}" .
