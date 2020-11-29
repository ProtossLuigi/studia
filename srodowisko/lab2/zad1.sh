#!/bin/bash
svn checkout https://repo.cs.pwr.edu.pl/244942
mv 244942 test1
cd test1
mkdir temp
touch temp/example.txt
svn add temp
svn commit -m ""
cd ..
svn checkout https://repo.cs.pwr.edu.pl/244942
mv 244942 test2
cd test2
echo aaa > temp/example.txt
svn commit -m ""
cd ../test1
echo bbb > temp/example.txt
svn update
echo aaa bbb > temp/example.txt
svn resolve --accept working temp/example.txt
svn commit -m ""
