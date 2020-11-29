#!/bin/bash
for f in $( find $1 -type f )
do
    tr 'a' 'A' < $f > temp.txt
    cat temp.txt > $f
done
rm temp.txt
