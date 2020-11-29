#!/bin/bash
files=$( svn list --depth infinity -r $1 $2@$1 | grep -v -w ".*/" )
words=""
for f in $files
do
    words+="$( svn cat -r $1 $2$f@$1 )"$'\n'
done
uwords=$( echo "$words" | tr "[:space:]" '\n' | sort | uniq )
for w in $uwords
do
    fcount=0
    for f in $files
    do
        if [[ $( svn cat -r $1 $2$f@$1 | grep -w $w) ]]
        then
            let fcount=$fcount+1
        fi
    done
    echo $w $fcount
done
