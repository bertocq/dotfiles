#!/usr/bin/env bash
_source_if() { [[ -r "$1" ]] && source "$1"; }

_source_if ~/.bashrc
_source_if ~/.bashrc$ENV_SUFFIX
