#!/bin/bash
files=$( find $1 -type f )
words=""
for f in $files
do
    words+="$( cat $f )"$'\n'
done
uwords=$( echo "$words" | tr "[:space:]" '\n' | sort | uniq )
IFS=$'\n'
for w in $uwords
do
    echo $w
    for f in $files
    do
        for line in $(cat $f | grep -w $w)
        do
            echo $f$'\t'$line
        done
    done
done
IFS=''
