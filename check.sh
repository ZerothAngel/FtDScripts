#!/bin/sh

if ! test -d out; then
  exit 0
fi

check_commons() {
  if fgrep Modules: "$1" | fgrep commons >/dev/null; then
    if ! egrep '^\W*C = Commons\.new' "$1" >/dev/null; then
      echo "missing call to Commons.new"
      return 1
    fi
  fi
  return 0
}

check_firstrun () {
  if fgrep Modules: "$1" | fgrep firstrun >/dev/null; then
    if ! egrep '^\W*FirstRun\(I\)' "$1" >/dev/null; then
      echo "missing call to FirstRun"
      return 1
    fi
  fi
  return 0
}

TEMP=$(mktemp /tmp/check.XXXXXX)
trap "rm -f $TEMP" EXIT

for f in out/*.lua; do
  if lua51 -l dummy "$f"; then
    echo -n "$f: "
    if check_commons "$f" && check_firstrun "$f"; then
      if luacheck "$f" >$TEMP; then
        echo "ok"
      else
        echo "luacheck"
        cat $TEMP
      fi
    fi
  fi
done
