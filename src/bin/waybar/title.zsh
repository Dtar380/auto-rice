#!/usr/bin/zsh
width=30
pad="   "
offset=0
last=""
tick=0
pstate=""
text="Nothing playing"

while true; do
  # Ask playerctl once per second (every 4th loop)
  if (( tick % 4 == 0 )); then
    pstate=$(playerctl status 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)

    if [[ -z $pstate ]]; then
      text="Nothing playing"
    elif [[ -n $title && -n $artist ]]; then
      text="$title - $artist"
    elif [[ -n $title ]]; then
      text=$title
    else
      text="Unknown track"
    fi
  fi
  (( tick++ ))

  # New track: restart the scroll
  if [[ $text != "$last" ]]; then
    offset=0
    last=$text
  fi

  if (( ${#text} <= width )); then
    print -r -- "$text"
  elif [[ $pstate == Playing ]]; then
    loop="$text$pad"
    doubled="$loop$loop"
    print -r -- "${doubled:$offset:$width}"
    offset=$(( (offset + 1) % ${#loop} ))
  else
    print -r -- "${text:0:$width}"
  fi

  sleep 0.25
done
