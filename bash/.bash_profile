#!/usr/bin/env bash
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

if [ -f ~/.bashrc$ENV_SUFFIX ]; then
  source ~/.bashrc$ENV_SUFFIX
fi
