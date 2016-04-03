#!/bin/bash

function convertData() {

grep "com.ibm" | cut -d: -f3,4 | sed 's/^ *//g' | sed 's/ : / /g' | sort | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
