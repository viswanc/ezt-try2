#!/bin/sh

# Backgrounds and logs the given commands stdin and stdout to the given file.

logFile=$1
shift # Remove the first argumet form $@ (a marker for all arguments).

echo "Running:\n\t$@\nFrom:\n\t$PWD"

$@ > $logFile 2>&1 &
