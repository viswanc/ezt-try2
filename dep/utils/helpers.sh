#!/bin/sh

# A set of helper functions, for other scripts.

filter () { # Fiters-in the lines of the input stream, which match the given awk regexp pattern.

  while read line
  do
    echo $line | awk -v regex=$1 'match($0, regex) {print $0}'
  done
}

retry () { # Retries a command until an expected result.

  # $1: Time to wait between attempts.
  # $2: Row identifier (regexp).
  # $3: Column number.
  # $4: Expected value.
  # $..:  Command to execute.

  while [ $(${@:5} | awk -v regex=$2 -v col=$3 -v val=$4 '$col==val && match($0, regex) {print $0}') ]
  do
    echo a
    sleep "$1"

  done
}
