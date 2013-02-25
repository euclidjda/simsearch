#! /bin/bash
pwd=`pwd`

osascript -e "tell application \"Terminal\"" \
    -e "tell application \"System Events\" to keystroke \"t\" using {command down}" \
    -e "do script \"cd $pwd; clear; rake jobs:work\" in front window" \
    -e "end tell"
    > /dev/null

osascript -e "tell application \"Terminal\"" \
    -e "tell application \"System Events\" to keystroke \"t\" using {command down}" \
    -e "do script \"cd $pwd; clear; unicorn_rails -c config/unicorn.development.rb\" in front window" \
    -e "end tell"
    > /dev/null
