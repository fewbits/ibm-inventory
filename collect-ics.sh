#!/bin/bash

function convertData() {

grep '\[Version:' | cut -d] -f1 | cut -d: -f2 | while read version; do echo "IBM WebSphere Interchange Server $version"; done | sort -n | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
