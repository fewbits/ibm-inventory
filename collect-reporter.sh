#!/bin/bash

function convertData() {

grep 'Netcool/Reporter' | sed 's/^ *//g'

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
