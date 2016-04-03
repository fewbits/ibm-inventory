#!/bin/bash

function convertData() {

grep '^Name:\|^Version:\|ServicePack:' | sed 's/^Name://g' | sed 's/^Version:/#1/g' | sed 's/^ServicePack:/#2/g' | sed 's/^ *//g' | tr -s ' ' | sed 's/#2 */#2/g' | sed 's/#1/|/g' | sed 's/#2/|/g' | sed 'N;s/\n|//' |sed 'N;s/\n|//' | while read version; do echo "IBM $version"; done | sort -n | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
