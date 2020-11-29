#!/bin/bash
files="$( svn list -R -r $1 $2@$1 | grep -v -w ".*/" )"
words=""
for f in $files
do
    words+="$( svn cat -r $1 $2$f@$1 )"$'\n'
done
words=$( echo "$words" | tr "[:space:]" '\n' | sort )
uwords=$( echo "$words" | uniq )
for word in $uwords
do
    echo "$word $(echo "$words" | grep -w -c "$word" )"
done
