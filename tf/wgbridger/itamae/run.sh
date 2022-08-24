#!/bin/bash -xe

if [ ! -e /etc/apt/sources.list.d/nekomit.list ]; then
  curl -Ssf https://sorah.jp/packaging/debian/C3FF3305.pub.txt -o /usr/share/keyrings/nekomit.asc
  echo "deb [signed-by=/usr/share/keyrings/nekomit.asc] http://deb.nekom.it/ $(grep VERSION_CODENAME /etc/os-release|cut -d= -f2) main" > /etc/apt/sources.list.d/nekomit.list
fi
if [ ! -e /usr/bin/mitamae ]; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y mitamae
fi

mitamae local $1
