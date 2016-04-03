#!/bin/bash

function convertData() {

grep -e '^\/.*..:..:' | awk '{print $2}' | while read version; do echo "DB2 $version"; done | sort -n | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
