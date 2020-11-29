#!/bin/bash
files=$( find $1 -type f )
words=""
for f in $files
do
    words+="$( cat $f )"$'\n'
done
uwords=$( echo "$words" | tr "[:space:]" '\n' | sort | uniq )
for w in $uwords
do
    fcount=0
    for f in $files
    do
        if [[ $(cat $f | grep -w $w) ]]
        then
            let fcount=$fcount+1
        fi
    done
    echo $w $fcount
done
