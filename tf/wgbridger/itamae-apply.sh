#!/bin/bash -xe

node=$1
shift

tar cf - ./itamae | ssh "$@" 'cat > itamae.tar'
ssh "$@" "tar xf itamae.tar && cd itamae && sudo ./run.sh ./node_${node}.rb"
