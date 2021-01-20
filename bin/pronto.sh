#!/usr/bin/env bash
# ~/bin/pronto.sh

if [[ $1 == 'sh' ]]; then
docker run -it --env USER --rm  \
  -v "$PWD":/usr/src/app        \
  -w /usr/src/app returnly-pronto:latest \
  bash
else
docker run -i --env USER --rm  \
  -v "$PWD":/usr/src/app        \
  -w /usr/src/app returnly-pronto:latest \
  bash -c 'NODE_PATH=$(npm root --global) PRONTO_VERBOSE=true pronto run --exit-code -c origin/master'
fi
