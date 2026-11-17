#!/usr/bin/zsh
# Prints waybar JSON for mako: bell icon + DND state

count=$(makoctl list 2>/dev/null | grep -c '^Notification')

if makoctl mode 2>/dev/null | grep -qx 'do-not-disturb'; then
  prefix="dnd-"
else
  prefix=""
fi

if [ "$count" -gt 0 ]; then
  state="notification"
else
  state="none"
fi

printf '{"alt":"%s%s","class":"%s%s","tooltip":"%s notification(s)"}\n' \
  "$prefix" "$state" "$prefix" "$state" "$count"
