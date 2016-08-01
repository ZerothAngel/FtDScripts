#!/bin/sh
PATH=/bin:/usr/bin:/usr/local/bin; export PATH

if ! test -d out; then
  exit 0
fi

check_firstrun () {
  if fgrep Modules: "$1" | fgrep firstrun >/dev/null; then
    if ! egrep 'if\W+FirstRun' "$1" >/dev/null; then
      echo "missing call to FirstRun"
      return 1
    fi 
  fi
  return 0
}

check_getselfinfo() {
  if fgrep Modules: "$1" | fgrep getselfinfo >/dev/null; then
    if ! egrep '^\W*GetSelfInfo' "$1" >/dev/null; then
      echo "missing call to GetSelfInfo"
      return 1
    fi
  fi
  return 0
}

check_now() {
  if egrep '(^|\W)Now\W' "$1" >/dev/null; then
    if ! egrep '\W*Now\W*=\W*I:GetTimeSinceSpawn' "$1" >/dev/null; then
      echo "missing Now"
      return 1
    fi
  fi
}

for f in out/*.lua; do
  if lua52 -l dummy "$f"; then
    echo -n "$f: "
    if check_firstrun "$f" && check_getselfinfo "$f" && check_now "$f"; then
      echo "ok"
    fi
  fi
done
