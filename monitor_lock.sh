#! /bin/bash

gdbus monitor -y -d org.freedesktop.login1  | grep LockedHint --line-buffered |
  while read line
  do
    amixer -d -D pulse sset Master 0% > /dev/null
  done

exit
