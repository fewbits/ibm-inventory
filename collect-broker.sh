#!/bin/bash

function convertData() {

grep 'MQSI_VERSION=' | sed 's/MQSI_VERSION=//g' | while read version; do echo "IBM WebSphere Message Broker $version"; done | sort -n | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
