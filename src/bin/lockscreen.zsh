#!/usr/bin/zsh

# Restart the Quickshell lockscreen: kill any running instance, then start a new one.
pattern='^(quickshell|qs) -c lockscreen$'

if pgrep -f "$pattern" >/dev/null; then
    pkill -f "$pattern"
    # Wait up to 2s for it to exit, then force it
    for i in {1..20}; do
        pgrep -f "$pattern" >/dev/null || break
        sleep 0.1
    done
    pkill -9 -f "$pattern" 2>/dev/null
fi

exec quickshell -c lockscreen
