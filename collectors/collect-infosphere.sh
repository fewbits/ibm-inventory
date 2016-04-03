#!/bin/bash

function convertData() {

grep 'Product productId' | sed 's/^ *//g' | sed 's/<Product productId="//g' | sed 's/" version="/ /g' | sed 's/"\/>//g' | sort | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
