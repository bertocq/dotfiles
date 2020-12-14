#!/bin/bash
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

if [ -f ~/.bash_returnly ]; then
  source ~/.bash_returnly
fi

if [ -f ~/.bash_returnly_aws_mfa ]; then
  source ~/.bash_returnly_aws_mfa
fi
