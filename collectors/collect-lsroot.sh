#!/bin/bash

function convertData() {

grep 'identityName\|version' | grep -v "<?xml" | sed 's/^ *//g' | sed 's/<identityName>//g' | sed 's/<\/identityName>/|/g' | sed 's/<version>//g' | sed 's/<\/version>//g' | awk '/\|$/ { printf("%s\t", $0); next } 1' | tr '|' ' ' | sed 's/\t//g' | sort | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
