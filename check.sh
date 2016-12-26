#!/bin/sh
PATH=/bin:/usr/bin:/usr/local/bin:$HOME/.luacheck/bin; export PATH

if ! test -d out; then
  exit 0
fi

check_commons() {
  if fgrep Modules: "$1" | fgrep commons >/dev/null; then
    if ! egrep '^\W*C = Commons\.create' "$1" >/dev/null; then
      echo "missing call to Commons.create"
      return 1
    fi
  fi
  return 0
}

for f in out/*.lua; do
  if lua52 -l dummy "$f"; then
    echo -n "$f: "
    if check_commons "$f"; then
      echo "ok"
    fi
  fi
done

# Run the scripts I most oftenly use through luacheck
for f in airship cameratrack dediblademaintainer dropquad gunshipquad interceptmanager repairquad repairsub scout shieldmanager submarine utility utilitysub warship; do
  luacheck out/$f.lua
done
