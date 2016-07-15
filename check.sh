#!/bin/sh
PATH=/bin:/usr/bin:/usr/local/bin; export PATH

if ! test -d out; then
  exit 0
fi

for f in out/*.lua; do
  if lua52 -l dummy $f; then
    echo "$f: ok"
  fi
done
