#!/bin/bash

function convertData() {

grep '^Name  \|^Version  ' | sed 's/^Name  //g' | sed 's/^Version  /|/g' | sed 'N;s/\n|//' | sed 's/^ *//g' | tr -s " " | sort | uniq

}

if [ $1 ]; then
  cat $1 | convertData
else
  touch /tmp/collect.tmp
  vim /tmp/collect.tmp
  cat /tmp/collect.tmp | convertData
  rm /tmp/collect.tmp
fi
