#!/bin/bash
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

if [ -f ~/.bashrc_returnly ]; then
   source ~/.bashrc_returnly
fi

if [ -f ~/.bash_returnly_aws_mfa ]; then
   source ~/.bash_returnly_aws_mfa
fi
