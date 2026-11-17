#!/usr/bin/zsh
case "$(playerctl status 2>/dev/null)" in
  Playing) s=playing ;;
  Paused)  s=paused ;;
  *)       s=stopped ;;
esac
printf '{"alt":"%s","class":"%s"}\n' "$s" "$s"
