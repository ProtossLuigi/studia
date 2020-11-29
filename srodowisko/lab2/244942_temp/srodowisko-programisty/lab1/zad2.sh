#!/bin/bash
files=$( find $1 -type f )
words=""
for f in $files
do
    words+="$( cat $f )"$'\n'
done
words=$( echo "$words" | tr "[:space:]" '\n' | sort )
uwords=$( echo "$words" | uniq )
for word in $uwords
do
    echo "$word $(echo "$words" | grep -w -c "$word" )"
done
