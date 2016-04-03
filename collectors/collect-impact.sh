#!/bin/bash

function convertData() {

grep -i 'impact version' | tr ':' ' ' | tr -s ' ' | sort | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
