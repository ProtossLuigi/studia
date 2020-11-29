#!/bin/bash
for f in $( find $1 -type f )
do
    input="$f"
    while IFS= read -r line
    do
        words=$( echo $line | tr -s "[:space:]" "\n" | sort | uniq )
        for word in $( echo $words )
        do
            count=$( echo "$line" | tr -s "[:space:]" "\n" | grep -x -c "$word" )
            if [[ $count > 1 ]]
            then
                echo $word$'\t'$f$'\t'$line
            fi
        done
    done < "$input"
done
