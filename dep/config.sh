#!/bin/sh

# Executes a kubectl command using all the configs from all the subdirs.

cd $(dirname "$0")

find . -type d -depth 1 -not -path '*/\.*' -exec kubectl $1 -f {} \;
